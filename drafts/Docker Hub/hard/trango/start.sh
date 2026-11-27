#!/usr/bin/env bash
# Runs nginx, the Flask API and the C++ discovery server side by side.
# Upstream uses a Python watchdog (py_fail.py). This script waits for the first child to exit,
# then stops the others, so the container restarts.
set -euo pipefail

RUN_DIR=/tmp/trango
mkdir -p /config/ssl \
  "${RUN_DIR}/client_body" "${RUN_DIR}/proxy" "${RUN_DIR}/fastcgi" "${RUN_DIR}/uwsgi" "${RUN_DIR}/scgi"

# TLS: generate a self-signed certificate only when none exists in /config/ssl.
# Mount your own cert.pem and key.pem there to replace it.
if [[ ! -s /config/ssl/cert.pem || ! -s /config/ssl/key.pem ]]; then
  umask 077
  openssl req -x509 -newkey rsa:4096 -nodes -days 3650 -subj "/CN=trango" \
    -keyout /config/ssl/key.pem -out /config/ssl/cert.pem
fi

# nginx config and the discovery server config go to /tmp, since /app is read-only.
cp /defaults/nginx.conf "${RUN_DIR}/nginx.conf"

# The discovery server reads config.ini from its working directory. Move it to 9443 so nginx can own 8443.
cp /app/bin/config.ini "${RUN_DIR}/config.ini"
sed -i -E 's/^port[[:space:]]*=.*/port=9443/' "${RUN_DIR}/config.ini"

api_pid=""
ws_pid=""
nginx_pid=""

cleanup() {
  kill -TERM "${api_pid}" "${ws_pid}" "${nginx_pid}" 2>/dev/null || true
}
trap cleanup TERM INT

(cd /app/api && exec /app/venv/bin/python api.py) &
api_pid=$!

(cd "${RUN_DIR}" && exec /app/bin/WebSocketWS) &
ws_pid=$!

/usr/sbin/nginx -c "${RUN_DIR}/nginx.conf" -g 'daemon off;' &
nginx_pid=$!

# Exit as soon as any child stops.
status=0
wait -n || status=$?
cleanup
wait || true
exit "${status}"
