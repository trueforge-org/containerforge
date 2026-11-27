#!/usr/bin/env bash
set -eu

HTTP_PORT="${HTTP_PORT:-8080}"

# writable state lives in /config (may be empty); scratch goes to /tmp
mkdir -p /config/bridges /config/formats /tmp/nginx /tmp/sessions
[[ -f /config/whitelist.txt ]] || touch /config/whitelist.txt

# UNVERIFIED: custom bridges/formats in /config are not yet loaded; upstream copied them into /app
sed "s/__HTTP_PORT__/${HTTP_PORT}/" /etc/nginx/rss-bridge.conf.template > /tmp/nginx/nginx.conf

nginx -c /tmp/nginx/nginx.conf -g "daemon off;" &

# UNVERIFIED: process model (nginx in background, php-fpm as the foreground process) needs a probe run
exec php-fpm8.5 --nodaemonize --fpm-config /etc/php/8.5/fpm/php-fpm.conf
