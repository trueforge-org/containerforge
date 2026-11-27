#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. Only /config (persistent) and /tmp (ephemeral) are written.
# Create the data folder and its index guard only when missing; never overwrite user data.
mkdir -p /config/data /tmp/nginx /tmp/php /tmp/php-sessions
[ -f /config/data/index.php ] || touch /config/data/index.php

# UNVERIFIED: the php-fpm binary name on ubuntu 26.04 (php-fpm<version> or php-fpm).
# -D daemonizes php-fpm; nginx stays in the foreground through exec so signals reach it.
php-fpm -y /etc/php/php-fpm.conf -D
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
