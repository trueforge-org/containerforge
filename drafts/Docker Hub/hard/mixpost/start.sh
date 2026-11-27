#!/usr/bin/env bash
# UNVERIFIED: PHP 8.5 and Laravel 12 compatibility, the Horizon and schedule commands, and the
# first-user command (`php artisan mixpost-auth:create`) are from the docs and are not yet tested.
set -euo pipefail

APP_DIR=/app/www
export APP_NAME="${APP_NAME:-Mixpost}"
export APP_DEBUG="${APP_DEBUG:-false}"
export APP_URL="${APP_URL:-}"
export TZ="${TZ:-Etc/UTC}"
export DB_HOST="${DB_HOST:-mariadb}"
export DB_PORT="${DB_PORT:-3306}"
export DB_DATABASE="${DB_DATABASE:-mixpost}"
export DB_USERNAME="${DB_USERNAME:-mixpost}"
export DB_PASSWORD="${DB_PASSWORD:-}"
export REDIS_HOST="${REDIS_HOST:-valkey}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export REDIS_PASSWORD="${REDIS_PASSWORD:-}"
export MIXPOST_DISK="${MIXPOST_DISK:-public}"
export LOG_CHANNEL="${LOG_CHANNEL:-stderr}"

mkdir -p /config/storage/app/public /config/storage/logs \
  /tmp/storage-framework/cache /tmp/storage-framework/sessions /tmp/storage-framework/views \
  /tmp/bootstrap-cache /tmp/nginx /tmp/php

# Without APP_URL or DB_PASSWORD, serve a plain setup page. The port still answers.
if [ -z "${APP_URL}" ] || [ -z "${DB_PASSWORD}" ]; then
  echo "WARNING: APP_URL and DB_PASSWORD must be set. Serving a setup page instead of Mixpost." >&2
  mkdir -p /tmp/setup
  echo "<!doctype html><title>Mixpost setup</title><p>Set APP_URL and DB_PASSWORD to start Mixpost.</p>" > /tmp/setup/index.html
  exec php -S 0.0.0.0:8080 -t /tmp/setup
fi

# The app key is kept in /config so stored tokens stay readable across restarts. Its value is never logged.
if [ -z "${APP_KEY:-}" ]; then
  if [ ! -s /config/.app_key ]; then
    (umask 077 && php "${APP_DIR}/artisan" key:generate --show > /config/.app_key)
    echo "Generated APP_KEY in /config/.app_key"
  fi
  APP_KEY="$(cat /config/.app_key)"
fi
export APP_KEY

# Wait for the database with a bounded retry. Only host and port are used.
db_ready=0
for attempt in $(seq 1 60); do
  if (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null; then
    db_ready=1
    break
  fi
  echo "Waiting for database at ${DB_HOST}:${DB_PORT} (attempt ${attempt}/60)"
  sleep 2
done
if [ "${db_ready}" -ne 1 ]; then
  echo "ERROR: database at ${DB_HOST}:${DB_PORT} is not reachable" >&2
  exit 1
fi

cd "${APP_DIR}"
# Migrations are idempotent and run on every start.
php artisan migrate --force

cp /etc/nginx/mixpost.conf.template /tmp/nginx/nginx.conf
cp /etc/php/mixpost-fpm.conf /tmp/php/fpm.conf

# nginx, php-fpm, Horizon and the scheduler run side by side. If any one exits, the container exits.
php-fpm8.5 -F -y /tmp/php/fpm.conf &
FPM_PID=$!

php artisan horizon &
HORIZON_PID=$!

(
  while true; do
    php artisan schedule:run || true
    sleep 60
  done
) &
SCHEDULER_PID=$!

nginx -c /tmp/nginx/nginx.conf -g 'daemon off;' &
NGINX_PID=$!

shutdown() {
  kill -TERM "${NGINX_PID}" "${HORIZON_PID}" "${FPM_PID}" "${SCHEDULER_PID}" 2>/dev/null || true
}
trap shutdown TERM INT

set +e
wait -n
status=$?
set -e
shutdown
wait 2>/dev/null || true
exit "${status}"
