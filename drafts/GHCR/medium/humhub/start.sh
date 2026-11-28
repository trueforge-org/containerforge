#!/usr/bin/env bash
set -euo pipefail

# HumHub writes dynamic.php through the browser installer; upstream's default config files are seeded below.
mkdir -p \
  /config/uploads \
  /config/assets \
  /config/themes \
  /config/protected-config \
  /config/modules \
  /config/runtime

# Seed upstream's default config files only when missing (never overwrite user state).
cp -Rn /app/humhub/protected/config.dist/. /config/protected-config/ || true

# Scratch for php-fpm sessions and nginx temp files (ephemeral /tmp).
mkdir -p \
  /tmp/php-sessions \
  /tmp/nginx/client_body \
  /tmp/nginx/proxy \
  /tmp/nginx/fastcgi \
  /tmp/nginx/uwsgi \
  /tmp/nginx/scgi

# supervisord starts php-fpm (PHP_* env via -d flags) and nginx (config in /defaults/nginx.conf).
exec supervisord -n -c /defaults/supervisord.conf
