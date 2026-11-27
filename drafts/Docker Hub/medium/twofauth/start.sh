#!/bin/bash
set -euo pipefail

APP_DIR=/app/2fauth
CONFIG_DIR=/config

# *_FILE variants, as the upstream entrypoint reads them (UNVERIFIED beyond APP_KEY and DB_*)
file_env() {
  local var="$1"
  local file_var="${var}_FILE"
  if [ -n "${!file_var:-}" ]; then
    export "$var"="$(cat "${!file_var}")"
  fi
}
for var in APP_KEY DB_DATABASE DB_USERNAME DB_PASSWORD DB_HOST MAIL_USERNAME MAIL_PASSWORD REDIS_PASSWORD; do
  file_env "$var"
done

mkdir -p \
  "$CONFIG_DIR/storage" \
  "$CONFIG_DIR/database" \
  /tmp/bootstrap \
  /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi \
  /tmp/php-fpm

# Seed storage from the build-time copy only when missing or empty (never overwrite user state)
if [ -z "$(ls -A "$CONFIG_DIR/storage" 2>/dev/null)" ]; then
  cp -a /usr/share/twofauth/storage.pristine/. "$CONFIG_DIR/storage/"
fi

# .env: create once from the upstream example
if [ ! -f "$CONFIG_DIR/.env" ] || [ ! -s "$CONFIG_DIR/.env" ]; then
  cp "$APP_DIR/.env.example" "$CONFIG_DIR/.env"
fi

# Generate APP_KEY once when neither the environment nor .env provides one
if [ -z "${APP_KEY:-}" ] && ! grep -q '^APP_KEY=base64:' "$CONFIG_DIR/.env"; then
  php "$APP_DIR/artisan" key:generate --force --no-interaction
fi

# SQLite file must exist before migrating
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
  touch "${DB_DATABASE:-/config/database/database.sqlite}"
fi

# Migrations on every start (idempotent), as the upstream entrypoint does
php "$APP_DIR/artisan" migrate --force

# Passport keys and clients, once per /config volume (UNVERIFIED: upstream reruns on COMMIT change)
if [ ! -f "$CONFIG_DIR/installed" ]; then
  php "$APP_DIR/artisan" passport:install --no-interaction
  touch "$CONFIG_DIR/installed"
fi

# Refresh caches; bootstrap caches live in /tmp via the APP_*_CACHE variables
php "$APP_DIR/artisan" config:clear --no-interaction || true

# Run nginx and php-fpm under supervisord so both are supervised; exec hands PID 1 over
exec supervisord -n -c /defaults/supervisord.conf
