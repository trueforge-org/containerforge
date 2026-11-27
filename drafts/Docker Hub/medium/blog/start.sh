#!/usr/bin/env bash
set -eu

# Persistent state (uploads, thumbnails, logs, SQLite DB) lives under /config
mkdir -p /config/data/i /config/data/t /config/data/logs

# Ephemeral runtime state lives under /tmp, never in /app
mkdir -p /tmp/nginx /tmp/sessions

if [ "${BLOG_PASS:-demo}" = "demo" ]; then
  echo "[blog] WARNING: BLOG_PASS is still the default 'demo'. Set BLOG_NICK and BLOG_PASS." >&2
fi

# Render the nginx and php-fpm configs into /tmp (read-only rootfs)
cp -f /defaults/nginx.conf /tmp/nginx.conf
cp -f /defaults/php-fpm.conf /tmp/php-fpm.conf

# UNVERIFIED: php-fpm binary name for php8.5
php-fpm8.5 -y /tmp/php-fpm.conf -D

# nginx stays in the foreground as the final process
exec nginx -e /dev/stderr -c /tmp/nginx.conf -g 'daemon off;'
