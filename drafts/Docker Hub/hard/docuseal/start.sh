#!/usr/bin/env bash
set -e

DATA_DIR="${WORKDIR:-/config/data}"

# /app/tmp and /app/log are symlinks into /tmp (see Dockerfile), so their targets must exist.
mkdir -p "${DATA_DIR}" /tmp/app-tmp/cache /tmp/app-log /tmp/bootsnap

# An empty DATABASE_URL would be read as a database URL, so drop it and use SQLite.
if [ -z "${DATABASE_URL:-}" ]; then
  unset DATABASE_URL
fi

# Generate the secret once and keep it in /config. The secret is only exported, never passed on the command line.
if [ -z "${SECRET_KEY_BASE:-}" ]; then
  if [ ! -s "${DATA_DIR}/.secret_key_base" ]; then
    (umask 077 && tr -dc 'a-f0-9' </dev/urandom | head -c 128 > "${DATA_DIR}/.secret_key_base")
  fi
  SECRET_KEY_BASE="$(cat "${DATA_DIR}/.secret_key_base")"
  export SECRET_KEY_BASE
fi

cd /app
# UNVERIFIED: puma config may already bind; -b adds the all-interfaces bind on port 3000.
exec /app/bin/bundle exec puma -C /app/config/puma.rb --dir /app -b tcp://0.0.0.0:3000
