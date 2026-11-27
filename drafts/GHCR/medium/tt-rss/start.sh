#!/usr/bin/env bash
set -eu

APP_ROOT=/config/html/tt-rss
SRC=/app/tt-rss
SCRIPT_ROOT="${SCRIPT_ROOT:-/app/tt-rss/.docker/app}"
# UNVERIFIED: binary name of the Ubuntu php8.5-fpm package.
PHP_FPM=/usr/sbin/php-fpm8.5
DB_HOST="${TTRSS_DB_HOST:-postgresql}"
DB_PORT="${TTRSS_DB_PORT:-5432}"
DB_USER="${TTRSS_DB_USER:-tt-rss}"

mkdir -p "${APP_ROOT}"

# Refresh code from the image on every start and keep user state (upstream startup.sh behaviour).
rsync -a \
  --exclude=cache --exclude=lock --exclude=config.php \
  --exclude=plugins.local --exclude=themes.local --exclude=templates.local \
  "${SRC}/" "${APP_ROOT}/"

# Seed image-bundled plugins only when missing, so user plugins are never overwritten.
if [ -d "${SRC}/plugins.local" ]; then
  cp -rn "${SRC}/plugins.local/." "${APP_ROOT}/plugins.local/" 2>/dev/null || true
fi

# config.docker.php reads its settings from the environment, so it is regenerated on every start.
cp "${SCRIPT_ROOT}/config.docker.php" "${APP_ROOT}/config.php"

# UNVERIFIED: upstream also creates cache subdirectories; match its startup.sh once it is read.
mkdir -p \
  "${APP_ROOT}/cache" \
  "${APP_ROOT}/lock" \
  "${APP_ROOT}/plugins.local" \
  "${APP_ROOT}/themes.local" \
  "${APP_ROOT}/templates.local"

# Wait a bounded time for PostgreSQL. php-fpm starts either way, so the container stays up without a database.
tries=0
until pg_isready -q -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}"; do
  tries=$((tries + 1))
  if [ "${tries}" -ge 30 ]; then
    echo "WARNING: PostgreSQL ${DB_HOST}:${DB_PORT} is not ready, skipping schema update" >&2
    break
  fi
  sleep 2
done

if pg_isready -q -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}"; then
  php "${APP_ROOT}/update.php" --update-schema=force-yes
fi

# Readiness marker checked by the chart. Written before php-fpm takes over.
touch "${APP_ROOT}/.app_is_ready"

# -g keeps the pid file in /tmp. UNVERIFIED: the global error_log path must also be writable on a read-only rootfs.
# pm.max_children and memory_limit are fixed in defaults/www.conf; the upstream PHP_WORKER_* variables are not wired yet.
exec "${PHP_FPM}" --nodaemonize --force-stderr -g /tmp/php-fpm.pid
