#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="/config/report"
REPORT_FILE="${REPORT_DIR}/index.html"
# UNVERIFIED: the log path and COMBINED format are assumptions; upstream goaccess.sh was not read
LOG_FILE="/opt/log/access.log"
NGINX_CONF="/tmp/goaccess-nginx.conf"

mkdir -p "$REPORT_DIR" /tmp/nginx-temp

# regenerate the static report on every start; the report is served by nginx below
if [[ -r "$LOG_FILE" ]] && goaccess "$LOG_FILE" --log-format=COMBINED -o "$REPORT_FILE"; then
  echo "report written to ${REPORT_FILE}"
else
  echo "no readable log at ${LOG_FILE} (or goaccess failed); serving a placeholder page"
  printf '<!doctype html><title>GoAccess</title><p>No report yet. Mount web server logs at %s and restart.</p>\n' \
    "$LOG_FILE" > "$REPORT_FILE"
fi

# nginx config lives in /tmp so the image stays read-only; pid and temp paths are also in /tmp
cat > "$NGINX_CONF" <<'EOF'
worker_processes 1;
pid /tmp/goaccess-nginx.pid;
error_log /dev/stderr warn;

events {
    worker_connections 256;
}

http {
    include /etc/nginx/mime.types;
    access_log off;
    client_body_temp_path /tmp/nginx-temp/client;
    proxy_temp_path /tmp/nginx-temp/proxy;
    fastcgi_temp_path /tmp/nginx-temp/fastcgi;
    uwsgi_temp_path /tmp/nginx-temp/uwsgi;
    scgi_temp_path /tmp/nginx-temp/scgi;

    server {
        listen 7889;
        root /config/report;
        index index.html;
    }
}
EOF

exec nginx -c "$NGINX_CONF" -g 'daemon off;'
