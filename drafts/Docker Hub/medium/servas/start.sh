#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. Persistent state goes to /config, scratch goes to /tmp.
mkdir -p \
    /config/database/sqlite \
    /config/storage/app/public \
    /config/storage/framework/cache \
    /config/storage/framework/sessions \
    /config/storage/framework/views \
    /config/storage/logs \
    /tmp/nginx \
    /tmp/servas/bootstrap \
    /tmp/servas/sessions \
    /tmp/servas/uploads

export APP_ENV="${APP_ENV:-production}"
export APP_DEBUG="${APP_DEBUG:-false}"
export APP_URL="${APP_URL:-http://localhost:8080}"
export DB_CONNECTION="${DB_CONNECTION:-sqlite}"
export DB_DATABASE="${DB_DATABASE:-/config/database/sqlite/database.sqlite}"
export SERVAS_ENABLE_REGISTRATION="${SERVAS_ENABLE_REGISTRATION:-false}"

# Laravel cache files go to /tmp because /app/bootstrap/cache is read-only.
# UNVERIFIED: these env names must be checked against the installed Laravel version.
export APP_CONFIG_CACHE=/tmp/servas/bootstrap/config.php
export APP_SERVICES_CACHE=/tmp/servas/bootstrap/services.php
export APP_PACKAGES_CACHE=/tmp/servas/bootstrap/packages.php
export APP_ROUTES_CACHE=/tmp/servas/bootstrap/routes.php
export APP_EVENTS_CACHE=/tmp/servas/bootstrap/events.php

if [ "${DB_CONNECTION}" = "sqlite" ]; then
    mkdir -p "$(dirname "${DB_DATABASE}")"
    # Create the file only when missing, never overwrite it.
    if [ ! -e "${DB_DATABASE}" ]; then
        touch "${DB_DATABASE}"
    fi
fi

# Generate APP_KEY once and keep it in /config. An APP_KEY from the environment wins.
if [ -z "${APP_KEY:-}" ]; then
    if [ ! -s /config/app.key ]; then
        (umask 077 && cd /app && php artisan key:generate --show > /config/app.key)
    fi
    APP_KEY="$(cat /config/app.key)"
fi
export APP_KEY

cd /app
php artisan migrate --force
php artisan config:cache
php artisan view:cache

# php-fpm runs in the background. nginx is the final exec so it receives signals.
php-fpm -y /etc/servas/php-fpm.conf &
exec nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
