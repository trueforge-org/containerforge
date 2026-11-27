#!/usr/bin/env bash
set -euo pipefail

# Persistent state (storage/, sqlite, uploads, generated keys) lives in /config.
# Runtime scratch (bootstrap cache, nginx and php-fpm sockets, pid files) lives in /tmp.
mkdir -p \
  /config/storage/app/public \
  /config/storage/build \
  /config/storage/database \
  /config/storage/debugbar \
  /config/storage/export \
  /config/storage/framework/cache/data \
  /config/storage/framework/sessions \
  /config/storage/framework/views \
  /config/storage/logs \
  /config/storage/upload \
  /tmp/bootstrap-cache \
  /tmp/php.d \
  /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi

# Generate the app key and the cron token once, then reuse them. Never print them.
# php-cli is used because it is already installed and avoids a pipeline that breaks under pipefail.
if [ -z "${APP_KEY:-}" ]; then
  if [ ! -s /config/storage/app_key ]; then
    umask 077
    php -r 'echo bin2hex(random_bytes(16));' > /config/storage/app_key
  fi
  APP_KEY="$(cat /config/storage/app_key)"
  export APP_KEY
fi

if [ -z "${STATIC_CRON_TOKEN:-}" ]; then
  if [ ! -s /config/storage/cron_token ]; then
    umask 077
    php -r 'echo bin2hex(random_bytes(16));' > /config/storage/cron_token
  fi
  STATIC_CRON_TOKEN="$(cat /config/storage/cron_token)"
  export STATIC_CRON_TOKEN
fi

# Database. The default is sqlite inside /config, so the image starts with no database container.
DB_CONNECTION="${DB_CONNECTION:-sqlite}"
case "$DB_CONNECTION" in
  sqlite)
    export DB_DATABASE="${DB_DATABASE:-/config/storage/database/database.sqlite}"
    touch "$DB_DATABASE"
    ;;
  pgsql|mysql)
    if [ -z "${DB_PORT:-}" ]; then
      if [ "$DB_CONNECTION" = "pgsql" ]; then DB_PORT=5432; else DB_PORT=3306; fi
      export DB_PORT
    fi
    if [ -n "${DB_HOST:-}" ]; then
      # Wait a while for the database, then carry on. Migrations will report any real failure.
      for _ in $(seq 1 30); do
        if nc -z "$DB_HOST" "$DB_PORT"; then break; fi
        sleep 1
      done
    fi
    ;;
  *)
    echo "Unsupported DB_CONNECTION: $DB_CONNECTION" >&2
    exit 1
    ;;
esac

# Render configs into /tmp. The defaults are static, so this copy is all the rendering there is.
cp /defaults/php-fpm.conf /tmp/php-fpm.conf
cp /defaults/php.ini /tmp/php.d/99-firefly.ini
cp /defaults/nginx.conf /tmp/nginx.conf

cd /app/www

# Upgrade steps on every start. They are safe to repeat.
# UNVERIFIED: the firefly-iii:* command names. Confirm with `php artisan list` on the first build.
php artisan migrate --force
php artisan firefly-iii:upgrade-database
php artisan firefly-iii:laravel-passport-keys
php artisan config:clear
php artisan view:clear

# Scheduler: a daily loop, since the image has no cron. UNVERIFIED cadence, check the upstream docs.
(
  while sleep 86400; do
    php /app/www/artisan firefly-iii:cron || echo "firefly-iii:cron exited with an error" >&2
  done
) &

# UNVERIFIED: the php-fpm binary name on 26.04 (php-fpm8.5).
php-fpm8.5 -F -y /tmp/php-fpm.conf &

# Known limit: nginx is PID 1 after exec and does not reap children. A supervisor is a follow-up.
exec nginx -c /tmp/nginx.conf -g 'daemon off;'
