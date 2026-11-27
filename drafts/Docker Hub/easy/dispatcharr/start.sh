#!/usr/bin/env bash
set -euo pipefail

# role: "web" (default) runs nginx and uwsgi; "celery" runs beat and the workers.
ROLE="${1:-web}"

cd /app

export DISPATCHARR_ENV=modular
export POSTGRES_HOST="${POSTGRES_HOST:-postgresql}" POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export POSTGRES_DB="${POSTGRES_DB:-dispatcharr}" POSTGRES_USER="${POSTGRES_USER:-dispatch}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-secret}"
export REDIS_HOST="${REDIS_HOST:-valkey}" REDIS_PORT="${REDIS_PORT:-6379}"
export DISPATCHARR_PORT="${DISPATCHARR_PORT:-9191}" DISPATCHARR_LOG_LEVEL="${DISPATCHARR_LOG_LEVEL:-info}"
export DISPATCHARR_TIME_ZONE="${DISPATCHARR_TIME_ZONE:-${TZ:-Etc/UTC}}"
export DISPATCHARR_LOG_DIR=/config/logs
export UWSGI_WORKERS="${UWSGI_WORKERS:-4}" CELERY_MAX_WORKERS="${CELERY_MAX_WORKERS:-6}" CELERY_MIN_WORKERS="${CELERY_MIN_WORKERS:-1}"
export CELERY_NICE_LEVEL="${CELERY_NICE_LEVEL:-5}"

mkdir -p /config/{backups,logos,cache/logos,cache/sd_posters,recordings,uploads/m3us,uploads/epgs,m3us,epgs,plugins,models,scripts,logs} /tmp/nginx

# secret key: created once, never printed
if [[ ! -f /config/jwt ]]; then
  (umask 077; python3 -c 'import secrets; print(secrets.token_urlsafe(64))' > /config/jwt.tmp)
  mv /config/jwt.tmp /config/jwt
fi
export DJANGO_SECRET_KEY="$(tr -d '\r\n' < /config/jwt)"

wait_for_database() {
  until pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -q; do
    echo "waiting for database ${POSTGRES_HOST}:${POSTGRES_PORT}"
    sleep 2
  done
}

wait_for_redis() {
  until python /app/scripts/wait_for_redis.py; do
    echo "waiting for redis ${REDIS_HOST}:${REDIS_PORT}"
    sleep 2
  done
}

if [[ "$ROLE" == "web" ]]; then
  # render the upstream site fragment with our port
  sed "s/NGINX_PORT/${DISPATCHARR_PORT}/g" /app/docker/nginx.conf > /tmp/dispatcharr-site.conf
  if [[ ! -s /proc/net/if_inet6 ]]; then
    sed -i '/listen \[::\]:/d' /tmp/dispatcharr-site.conf
  fi

  # nginx answers 502 until uwsgi is up, so the port opens even without a database
  nginx -g 'daemon off;' -c /etc/dispatcharr/nginx.conf &
  NGINX_PID=$!

  wait_for_database
  wait_for_redis
  python manage.py migrate --noinput

  uwsgi_args=(--ini /app/docker/uwsgi.modular.ini)
  if [[ "${DISPATCHARR_DEBUG:-false}" != "true" ]]; then
    uwsgi_args+=(--disable-logging)
  fi
  /app/venv/bin/uwsgi "${uwsgi_args[@]}" &
  UWSGI_PID=$!

  # deliberate exception to the final-exec rule: supervise both, forward TERM, exit when either dies
  trap 'kill -TERM "$NGINX_PID" "$UWSGI_PID" 2>/dev/null || true' TERM INT
  wait -n || true
  kill -TERM "$NGINX_PID" "$UWSGI_PID" 2>/dev/null || true
  exit 1

elif [[ "$ROLE" == "celery" ]]; then
  wait_for_database
  until python manage.py migrate --check >/dev/null 2>&1; do
    echo "waiting for migrations"
    sleep 2
  done

  nice -n "$CELERY_NICE_LEVEL" celery --quiet -A dispatcharr beat -l info &
  nice -n "$CELERY_NICE_LEVEL" celery --quiet -A dispatcharr worker -Q dvr -n dvr@%h --pool=threads --concurrency=20 -l info &
  exec nice -n "$CELERY_NICE_LEVEL" celery --quiet -A dispatcharr worker -Q celery,plugins -n default@%h \
    --autoscale="${CELERY_MAX_WORKERS},${CELERY_MIN_WORKERS}" -l info

else
  echo "unknown role: ${ROLE}" >&2
  exit 1
fi
