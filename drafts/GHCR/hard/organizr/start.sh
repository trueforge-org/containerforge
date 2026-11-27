#!/usr/bin/env bash
set -euo pipefail

# Persistent state only. Nothing is written to /app.
mkdir -p /config

# UNVERIFIED: nginx and php-fpm configs are expected under etc/ (not yet written). Both use /tmp for pid, socket and temp files.
php-fpm --nodaemonize --fpm-config /etc/organizr/php-fpm.conf &

exec nginx -g 'daemon off;' -c /etc/organizr/nginx.conf
