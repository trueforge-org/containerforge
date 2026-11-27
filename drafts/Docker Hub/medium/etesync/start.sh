#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/media

# ConfigParser interpolation: escape percent signs in values.
esc() { printf '%s' "${1//%/%%}"; }

if [ "${DATABASE_ENGINE:-sqlite}" = "postgresql" ]; then
  : "${POSTGRES_HOST:?POSTGRES_HOST is required when DATABASE_ENGINE=postgresql}"
fi

ini="${ETEBASE_EASY_CONFIG_PATH:-/tmp/etebase-server.ini}"
umask 077
{
  echo "[global]"
  echo "secret_file = /config/secret.txt"
  echo "debug = false"
  echo "media_root = /config/media"
  echo "static_root = /app/static"
  if [ -n "${ETEBASE_REDIS_URI:-}" ]; then
    echo "redis_uri = $(esc "${ETEBASE_REDIS_URI}")"
  fi
  echo "[allowed_hosts]"
  # UNVERIFIED: key format allowed_host<N> for the ini file.
  i=0
  IFS=',' read -ra hosts <<< "${ETEBASE_ALLOWED_HOSTS:-*}"
  for h in "${hosts[@]}"; do
    i=$((i+1))
    echo "allowed_host${i} = $(esc "$h")"
  done
  echo "[database]"
  if [ "${DATABASE_ENGINE:-sqlite}" = "postgresql" ]; then
    echo "engine = django.db.backends.postgresql"
    echo "name = $(esc "${POSTGRES_DB:-etesync}")"
    echo "user = $(esc "${POSTGRES_USER:-etesync}")"
    echo "password = $(esc "${POSTGRES_PASSWORD:-}")"
    echo "host = $(esc "${POSTGRES_HOST}")"
    echo "port = $(esc "${POSTGRES_PORT:-5432}")"
  else
    echo "engine = django.db.backends.sqlite3"
    echo "name = /config/db.sqlite3"
  fi
} > "$ini"
export ETEBASE_EASY_CONFIG_PATH="$ini"

cd /app/etesync
/app/venv/bin/python manage.py migrate --no-input
exec /app/venv/bin/uvicorn etebase_server.asgi:application --host 0.0.0.0 --port 8000
