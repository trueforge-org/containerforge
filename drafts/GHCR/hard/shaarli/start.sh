#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/cache /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi

# Shaarli creates its config on the first visit to the setup wizard. Existing files are never overwritten.
# php-fpm daemonizes. Its pid file and error log are set in the image (see Dockerfile).
php-fpm8.5 -y /etc/php/8.5/fpm/php-fpm.conf -D

exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"
