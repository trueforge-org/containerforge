#!/usr/bin/env bash
set -euo pipefail

SEAFILE_DIR=/app/seafile-server
SEAFILE_STATE=/config/seafile
CONF_DIR="${SEAFILE_STATE}/conf"
CCNET_DIR="${SEAFILE_STATE}/ccnet"
DATA_DIR="${SEAFILE_STATE}/seafile-data"
SEAHUB_DATA_DIR="${SEAFILE_STATE}/seahub-data"
LOG_DIR="${SEAFILE_STATE}/logs"
PID_DIR=/tmp/seafile-pids

: "${SEAFILE_MYSQL_DB_HOST:=mariadb}"
: "${SEAFILE_MYSQL_DB_PORT:=3306}"
: "${SEAFILE_MYSQL_DB_USER:=seafile}"
: "${SEAFILE_MYSQL_DB_PASSWORD:=}"
: "${SEAFILE_MYSQL_DB_CCNET_DB_NAME:=ccnet_db}"
: "${SEAFILE_MYSQL_DB_SEAFILE_DB_NAME:=seafile_db}"
: "${SEAFILE_MYSQL_DB_SEAHUB_DB_NAME:=seahub_db}"
: "${INIT_SEAFILE_ADMIN_EMAIL:=me@example.com}"
: "${INIT_SEAFILE_ADMIN_PASSWORD:=}"
: "${SEAFILE_SERVER_HOSTNAME:=localhost}"
: "${SEAFILE_SERVER_PROTOCOL:=http}"
: "${JWT_PRIVATE_KEY:=}"
: "${CACHE_PROVIDER:=redis}"
: "${REDIS_HOST:=valkey}"
: "${REDIS_PORT:=6379}"
: "${REDIS_PASSWORD:=}"
: "${MEMCACHED_HOST:=memcached}"
: "${MEMCACHED_PORT:=11211}"
: "${TIME_ZONE:=UTC}"

mkdir -p "${CONF_DIR}" "${CCNET_DIR}" "${DATA_DIR}" "${SEAHUB_DATA_DIR}" "${LOG_DIR}" "${PID_DIR}" /tmp/nginx
export TZ="${TIME_ZONE}"

# Front proxy first, so port 8080 answers while the rest waits for the database.
# nginx daemonizes by default.
nginx -c /defaults/nginx.conf

# JWT key: use the env value when set, otherwise generate one once and keep it in /config.
# The key is exported, never printed.
if [[ -z "${JWT_PRIVATE_KEY}" ]]; then
  if [[ ! -s "${SEAFILE_STATE}/jwt.key" ]]; then
    openssl rand -hex 32 > "${SEAFILE_STATE}/jwt.key"
    chmod 600 "${SEAFILE_STATE}/jwt.key"
  fi
  JWT_PRIVATE_KEY="$(cat "${SEAFILE_STATE}/jwt.key")"
fi
export JWT_PRIVATE_KEY

# Wait for MariaDB. Without a database the container keeps serving the 502 page from nginx.
echo "waiting for database ${SEAFILE_MYSQL_DB_HOST}:${SEAFILE_MYSQL_DB_PORT}"
until (exec 3<>"/dev/tcp/${SEAFILE_MYSQL_DB_HOST}/${SEAFILE_MYSQL_DB_PORT}") 2>/dev/null; do
  sleep 2
done

if [[ ! -f "${SEAFILE_STATE}/.setup-done" ]]; then
  if [[ -z "${SEAFILE_MYSQL_DB_PASSWORD}" ]]; then
    echo "SEAFILE_MYSQL_DB_PASSWORD is not set, cannot run first-time setup" >&2
    exit 1
  fi
  # UNVERIFIED: the first-run helper is not wired yet. Read the upstream setup script
  # (setup-seafile-mysql.py) and pass the DB password through the environment, never argv.
  echo "first-time setup is not implemented in this draft" >&2
  exit 1
fi

# Seahub admin, created only when a password is given. Passed through the environment.
# UNVERIFIED: manage.py path and the createsuperuser env support in this Seahub version.
if [[ -n "${INIT_SEAFILE_ADMIN_PASSWORD}" && ! -f "${SEAFILE_STATE}/.admin-done" ]]; then
  (
    cd "${SEAFILE_DIR}/seahub"
    DJANGO_SUPERUSER_PASSWORD="${INIT_SEAFILE_ADMIN_PASSWORD}" \
      /app/venv/bin/python manage.py createsuperuser --noinput --email "${INIT_SEAFILE_ADMIN_EMAIL}"
  ) && touch "${SEAFILE_STATE}/.admin-done"
fi

# Fileserver in the background (port 8082). UNVERIFIED: binary path and flags (plan section 7).
"${SEAFILE_DIR}/seafile/bin/seaf-server" \
  -c "${CCNET_DIR}" -d "${DATA_DIR}" -F "${CONF_DIR}" \
  -l "${LOG_DIR}/seafile.log" -P "${PID_DIR}/seafile.pid" &

# Seahub on gunicorn is the foreground process, bound to localhost behind nginx.
cd "${SEAFILE_DIR}/seahub"
exec /app/venv/bin/gunicorn seahub.wsgi:application \
  --bind 127.0.0.1:8000 \
  --workers 3 \
  --timeout 1200 \
  --pid "${PID_DIR}/gunicorn.pid"
