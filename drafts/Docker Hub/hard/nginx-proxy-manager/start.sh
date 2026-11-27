#!/usr/bin/env bash
# Runs OpenResty (nginx) and the Node backend side by side.
# Upstream uses s6-overlay. This image has no init system, so the script supervises both processes
# and exits when either one stops, which lets the orchestrator restart the container.
set -euo pipefail

# Persistent state lives in /config. Ephemeral nginx paths live in /tmp.
# UNVERIFIED: the exact directory set the backend expects on first start.
mkdir -p \
  /config/data/nginx/default_host \
  /config/data/nginx/proxy_host \
  /config/data/nginx/redirection_host \
  /config/data/nginx/dead_host \
  /config/data/nginx/stream \
  /config/data/nginx/temp \
  /config/data/nginx/custom \
  /config/data/logs \
  /config/data/access \
  /config/data/letsencrypt-acme-challenge \
  /config/letsencrypt \
  /tmp/nginx/body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi /tmp/nginx/cache

# Seed a writable venv for certbot plugins. /app/venv itself stays read-only.
if [[ ! -x /config/venv/bin/python ]]; then
  rm -rf /config/venv
  cp -a /app/venv /config/venv
fi
export PATH="/config/venv/bin:${PATH}"

cleanup() {
  kill -TERM "${nginx_pid:-}" "${backend_pid:-}" 2>/dev/null || true
}
trap cleanup TERM INT

/usr/local/bin/nginx -g 'daemon off;' &
nginx_pid=$!

cd /app/npm
node --max_old_space_size=250 index.js &
backend_pid=$!

# Exit as soon as either process stops.
status=0
wait -n || status=$?
cleanup
wait || true
exit "${status}"
