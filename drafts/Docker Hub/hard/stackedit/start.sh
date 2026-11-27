#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/sites /tmp/nginx-temp/client_body /tmp/nginx-temp/proxy \
  /tmp/nginx-temp/fastcgi /tmp/nginx-temp/uwsgi /tmp/nginx-temp/scgi

# Seed the site config once. Keep user edits afterwards.
if [[ ! -f /config/sites/default.conf ]]; then
  cp /defaults/default.conf /config/sites/default.conf
fi

# The main nginx config is regenerated under /tmp on every start, so the rootfs stays read-only.
cp /defaults/nginx.conf /tmp/nginx.conf

exec nginx -c /tmp/nginx.conf -g 'daemon off;'
