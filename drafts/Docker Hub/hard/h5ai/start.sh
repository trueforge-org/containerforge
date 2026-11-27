#!/usr/bin/env bash
set -euo pipefail

# Runtime state lives in /tmp (ephemeral) and /config (persistent); /app is read-only
mkdir -p /config \
  /tmp/h5ai/public-cache /tmp/h5ai/private-cache \
  /tmp/nginx-temp/client /tmp/nginx-temp/proxy /tmp/nginx-temp/fastcgi \
  /tmp/nginx-temp/uwsgi /tmp/nginx-temp/scgi /tmp/php

echo "WARNING: h5ai has no authentication; anyone who can reach port 8080 can browse /h5ai" >&2

cp /defaults/nginx.conf /tmp/nginx.conf

php-fpm8.5 -F -y /defaults/php-fpm.conf &
nginx -c /tmp/nginx.conf -g 'daemon off;' &

trap 'kill -TERM $(jobs -p) 2>/dev/null || true' TERM INT

# Exit as soon as either process stops, and stop the other one
wait -n
status=$?
kill -TERM $(jobs -p) 2>/dev/null || true
exit "${status}"
