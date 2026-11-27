#!/usr/bin/env bash
set -e

mkdir -p /config/plugins /config/caddy /tmp/caddy /tmp/supervisor

# Required: the database password. Fail early with a clear message.
: "${DATABASE_PASSWORD:?DATABASE_PASSWORD must be set}"

# Generated once into /config, unless SECRET_KEY is given.
if [ -z "${SECRET_KEY:-}" ]; then
  if [ ! -s /config/.secret ]; then
    head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/.secret
  fi
  SECRET_KEY="$(cat /config/.secret)"
fi
export SECRET_KEY
export BASEROW_AMOUNT_OF_GUNICORN_WORKERS="${BASEROW_AMOUNT_OF_GUNICORN_WORKERS:-2}"

cp /defaults/Caddyfile /tmp/caddy/Caddyfile
cp /defaults/supervisord.conf /tmp/supervisor/supervisord.conf

# Wait for postgresql, then migrate on every start. The process stays up and retries while the database is not ready.
# UNVERIFIED: the migrate command. Confirm it against the upstream backend entrypoint.
(
  cd /app/baserow/backend
  until python manage.py migrate --noinput; do
    echo "waiting for the database, retrying in 5 seconds"
    sleep 5
  done
)

exec supervisord -n -c /tmp/supervisor/supervisord.conf
