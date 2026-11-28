#!/usr/bin/env bash
# Rootless replacement for upstream docker/entrypoint.sh (all-in-one layout, external
# PostgreSQL and Redis/Valkey). Unresolved: not run. Upstream's log collector, hardware
# acceleration check and legacy NumPy switch are not reproduced.
set -euo pipefail

export HOME=/config
export VIRTUAL_ENV=/app/venv
export PATH="${VIRTUAL_ENV}/bin:${PATH}"

validate_workers() {
    local name="$1" value="$2"
    if ! [[ "${value}" =~ ^[0-9]+$ ]] || [ "${value}" -lt 1 ] || [ "${value}" -gt 20 ]; then
        echo "Error: ${name} must be an integer between 1 and 20 (got '${value}')." >&2
        exit 1
    fi
}

export POSTGRES_DB="${POSTGRES_DB:-dispatcharr}"
export POSTGRES_USER="${POSTGRES_USER:-dispatch}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-secret}"
export POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export REDIS_HOST="${REDIS_HOST:-localhost}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export REDIS_DB="${REDIS_DB:-0}"
export REDIS_IDLE_TIMEOUT="${REDIS_IDLE_TIMEOUT:-300}"
export REDIS_MAX_CONNECTIONS="${REDIS_MAX_CONNECTIONS:-50}"
export DISPATCHARR_PORT="${DISPATCHARR_PORT:-9191}"
export DISPATCHARR_LOG_LEVEL="${DISPATCHARR_LOG_LEVEL:-INFO}"
DISPATCHARR_LOG_LEVEL="${DISPATCHARR_LOG_LEVEL^^}"
export DISPATCHARR_TIME_ZONE="${DISPATCHARR_TIME_ZONE:-${TZ:-UTC}}"

export UWSGI_WORKERS="${UWSGI_WORKERS:-4}"
export CELERY_MAX_WORKERS="${CELERY_MAX_WORKERS:-6}"
export CELERY_MIN_WORKERS="${CELERY_MIN_WORKERS:-1}"
validate_workers UWSGI_WORKERS "${UWSGI_WORKERS}"
validate_workers CELERY_MAX_WORKERS "${CELERY_MAX_WORKERS}"
validate_workers CELERY_MIN_WORKERS "${CELERY_MIN_WORKERS}"
if [ "${CELERY_MIN_WORKERS}" -gt "${CELERY_MAX_WORKERS}" ]; then
    echo "Error: CELERY_MIN_WORKERS cannot exceed CELERY_MAX_WORKERS." >&2
    exit 1
fi
# Celery is spawned by uWSGI, so nice is relative to uWSGI's level.
export UWSGI_NICE_LEVEL="${UWSGI_NICE_LEVEL:-0}"
export CELERY_NICE_LEVEL="$(( ${CELERY_NICE_LEVEL:-5} - UWSGI_NICE_LEVEL ))"

if ! [[ "${DISPATCHARR_PORT}" =~ ^[0-9]+$ ]]; then
    echo "Warning: DISPATCHARR_PORT is not a number, using 9191." >&2
    export DISPATCHARR_PORT=9191
fi

# Persistent state: upstream code hardcodes /data.
for dir in backups logos cache/logos cache/sd_posters recordings uploads/m3us uploads/epgs \
           m3us epgs plugins models scripts logs; do
    mkdir -p "/data/${dir}"
done

# Django secret key: generate once and keep on the data volume.
SECRET_FILE=/data/jwt
if [ ! -s "${SECRET_FILE}" ]; then
    echo "Generating new Django secret key..."
    umask 077
    python -c 'import secrets; print(secrets.token_urlsafe(64))' > "${SECRET_FILE}"
    umask 022
fi
DJANGO_SECRET_KEY="$(tr -d '\r\n' < "${SECRET_FILE}")"
export DJANGO_SECRET_KEY

# Render nginx config into /tmp (rootfs is read-only).
mkdir -p /tmp/nginx
sed "s/NGINX_PORT/${DISPATCHARR_PORT}/g" /etc/dispatcharr/site.conf > /tmp/nginx/site.conf
if [ ! -s /proc/net/if_inet6 ]; then
    sed -i '/listen \[::\]:/d' /tmp/nginx/site.conf
fi

pids=()
cleanup() {
    trap - TERM INT
    for pid in "${pids[@]}"; do
        kill -TERM "${pid}" 2>/dev/null || true
    done
    wait 2>/dev/null || true
}
trap cleanup TERM INT

# Start nginx first so the port is open while the database comes up.
nginx -e /dev/stderr -c /etc/dispatcharr/nginx.conf -g 'daemon off;' &
pids+=("$!")

cd /app
echo "Waiting for PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT} and running migrations..."
until python manage.py migrate --noinput; do
    echo "Migration failed (database not ready?), retrying in 5s..." >&2
    sleep 5
done

# uWSGI runs the web app, daphne and the celery workers (attach-daemon in uwsgi.ini).
UWSGI_ARGS=(--ini /etc/dispatcharr/uwsgi.ini)
if [ "${DISPATCHARR_DEBUG:-false}" != "true" ]; then
    UWSGI_ARGS+=(--disable-logging)
fi
nice -n "${UWSGI_NICE_LEVEL}" uwsgi "${UWSGI_ARGS[@]}" &
pids+=("$!")

# Exit when either process stops, then stop the other.
set +e
wait -n
status=$?
cleanup
exit "${status}"
