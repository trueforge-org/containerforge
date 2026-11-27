#!/bin/sh
set -eu

# Persistent data for the symlinks made at build time. Only creates directories, no seeding.
# UNVERIFIED: whether HumHub's first run needs seeded files in /config/config.
mkdir -p /config/uploads /config/config /config/modules
mkdir -p /tmp/nginx-client /tmp/nginx-proxy /tmp/nginx-fastcgi /tmp/nginx-scgi /tmp/nginx-uwsgi

# /etc is read-only at runtime, so render the config into /tmp instead of editing it.
# Only the listed placeholders are replaced, so nginx variables such as $uri are untouched.
sed \
    -e "s|@NGINX_UPSTREAM@|${NGINX_UPSTREAM:-humhub:9000}|g" \
    -e "s|@NGINX_CLIENT_MAX_BODY_SIZE@|${NGINX_CLIENT_MAX_BODY_SIZE:-10m}|g" \
    -e "s|@NGINX_KEEPALIVE_TIMEOUT@|${NGINX_KEEPALIVE_TIMEOUT:-65}|g" \
    /etc/nginx/humhub.conf.template > /tmp/nginx.conf

echo "Starting HumHub nginx frontend on 8080"
exec nginx -c /tmp/nginx.conf -g "daemon off;"
