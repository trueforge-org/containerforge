#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/app/www
ENV_FILE=/config/.env

mkdir -p \
  /config/storage/app/public \
  /config/storage/framework/cache \
  /config/storage/framework/sessions \
  /config/storage/framework/views \
  /config/storage/logs \
  /config/gnupg \
  /tmp/bootstrap-cache \
  /tmp/nginx \
  /tmp/php
chmod 700 /config/gnupg

# Seed .env from the upstream example only when it is missing.
if [ ! -f "$ENV_FILE" ]; then
  cp "${APP_DIR}/.env.example" "$ENV_FILE"
fi
chmod 600 "$ENV_FILE"

# Write KEY="value" into .env, replacing any existing line. The value only reaches sed on stdin.
# UNVERIFIED: how phpdotenv treats a literal "$" in double-quoted values.
set_env() {
  local key="$1" value="$2" escaped
  escaped="$(printf '%s' "$value" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
  sed -i "/^${key}=/d" "$ENV_FILE"
  printf '%s="%s"\n' "$key" "$escaped" >> "$ENV_FILE"
}

# Apply settings from the environment on every start. Unset variables leave .env alone.
for key in APP_KEY APP_URL ANONADDY_DOMAIN ANONADDY_SECRET ANONADDY_ENABLE_REGISTRATION \
  DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD QUEUE_CONNECTION REDIS_HOST REDIS_PORT; do
  if [ -n "${!key:-}" ]; then
    set_env "$key" "${!key}"
  fi
done

# Generate secrets once, only when neither the environment nor .env has them. They persist in /config/.env.
ensure_secret() {
  local key="$1" generated="$2" current
  current="$(sed -n "s/^${key}=//p" "$ENV_FILE" | head -n 1 | tr -d '"')"
  if [ -z "$current" ]; then
    set_env "$key" "$generated"
  fi
}
ensure_secret APP_KEY "base64:$(openssl rand -base64 32)"
ensure_secret ANONADDY_SECRET "$(openssl rand -hex 32)"

# Wait for the database, then run migrations. Without DB_HOST the web UI still starts.
if [ -n "${DB_HOST:-}" ]; then
  port="${DB_PORT:-3306}"
  timeout_s="${DB_TIMEOUT:-60}"
  ready=0
  for _ in $(seq 1 "${timeout_s}"); do
    if (echo > "/dev/tcp/${DB_HOST}/${port}") 2>/dev/null; then
      ready=1
      break
    fi
    sleep 1
  done
  if [ "$ready" -eq 1 ]; then
    (cd "$APP_DIR" && php artisan migrate --force)
  else
    echo "WARNING: database ${DB_HOST}:${port} not reachable after ${timeout_s}s, skipping migrations" >&2
  fi
else
  echo "DB_HOST not set, skipping migrations"
fi

# php-fpm listens on a unix socket in /tmp.
php-fpm8.5 -y /etc/anonaddy/php-fpm.conf -F &
FPM_PID=$!

# Scheduler replaces the upstream cron service.
(
  while true; do
    (cd "$APP_DIR" && php artisan schedule:run) || true
    sleep 60
  done
) &

if [ "${QUEUE_CONNECTION:-sync}" = "redis" ]; then
  (cd "$APP_DIR" && exec php artisan queue:work --sleep=3 --tries=3) &
fi

# If php-fpm exits, stop the container instead of serving 502 errors silently.
(
  while kill -0 "$FPM_PID" 2>/dev/null; do
    sleep 5
  done
  echo "php-fpm exited" >&2
  kill -TERM $$
) &

# nginx is the foreground process on port 8000.
exec nginx -c /etc/anonaddy/nginx.conf -g 'daemon off;'
