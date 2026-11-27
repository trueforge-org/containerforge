#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/rw /config/log /config/logs /config/sites \
  /tmp/nginx-temp/client_body /tmp/nginx-temp/proxy /tmp/nginx-temp/fastcgi \
  /tmp/nginx-temp/uwsgi /tmp/nginx-temp/scgi

# Seed the site config once. Keep user edits afterwards.
if [[ ! -f /config/sites/default.conf ]]; then
  cp /defaults/default.conf /config/sites/default.conf
fi

# Main nginx config is regenerated under /tmp on every start, so /app and the rootfs stay read-only.
cp /defaults/nginx.conf /tmp/nginx.conf

# php-fpm runs in the background. Signal forwarding to it is a known gap for this draft.
php-fpm8.5 --nodaemonize --fpm-config /etc/php/8.5/fpm/php-fpm.conf &

for _ in $(seq 1 30); do
  [[ -S /tmp/php-fpm.sock ]] && break
  sleep 1
done

exec nginx -c /tmp/nginx.conf -g 'daemon off;'
