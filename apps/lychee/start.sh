#!/usr/bin/env bash

set -euo pipefail

APP_DIR=/config/www

mkdir -p \
    "${APP_DIR}" \
    /config/pictures/import \
    /config/sym \
    /config/log/lychee

if [[ ! -f "${APP_DIR}/artisan" ]]; then
    cp -a /app/www/. "${APP_DIR}/"
fi

if [[ ! -L "${APP_DIR}/public/uploads" ]]; then
    rm -rf "${APP_DIR}/public/uploads"
    ln -s /config/pictures "${APP_DIR}/public/uploads"
fi

if [[ ! -L "${APP_DIR}/public/sym" ]]; then
    rm -rf "${APP_DIR}/public/sym"
    ln -s /config/sym "${APP_DIR}/public/sym"
fi

if [[ ! -L "${APP_DIR}/storage/logs" ]]; then
    rm -rf "${APP_DIR}/storage/logs"
    ln -s /config/log/lychee "${APP_DIR}/storage/logs"
fi

if [[ ! -e /config/.env ]]; then
    cp "${APP_DIR}/.env.example" /config/.env
fi

if ! grep -q '^DB_CONNECTION=' /config/.env; then
    echo 'DB_CONNECTION=sqlite' >> /config/.env
fi
if ! grep -q '^DB_DATABASE=' /config/.env; then
    echo 'DB_DATABASE=/config/database.sqlite' >> /config/.env
fi

touch /config/database.sqlite

if [[ ! -L "${APP_DIR}/.env" ]]; then
    rm -f "${APP_DIR}/.env"
    ln -s /config/.env "${APP_DIR}/.env"
fi

cd "${APP_DIR}"

# Clear bootstrap cache
rm -rf bootstrap/cache/*.php 2>/dev/null || true

if grep -qPe '^APP_KEY=$' /config/.env; then
    php artisan key:generate --no-interaction
fi

php artisan migrate --force 2>/dev/null || {
    echo "⚠️  Migration failed, but continuing (database may not be configured yet)"
}

# Clear and cache configuration
php artisan config:clear 2>/dev/null || true
php artisan config:cache 2>/dev/null || true
php artisan route:clear 2>/dev/null || true
php artisan route:cache 2>/dev/null || true
php artisan view:clear 2>/dev/null || true
php artisan view:cache 2>/dev/null || true

# Start PHP development server on port 8000
exec php -S 0.0.0.0:8000 -t public
