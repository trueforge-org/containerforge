#!/usr/bin/env bash
set -eu

# persistent data, logs and backups live in /config (an empty /config is fine)
mkdir -p /config/data /config/logs /config/backups

# the SQLite cache dir is <data>/cache (hard-coded upstream). Keep it in /tmp, not /config.
# ln -sfn recreates the link on each start, since /tmp is empty after a restart.
mkdir -p /tmp/spoolman/cache
ln -sfn /tmp/spoolman/cache /config/data/cache

export SPOOLMAN_DIR_DATA="${SPOOLMAN_DIR_DATA:-/config/data}"
export SPOOLMAN_DIR_LOGS="${SPOOLMAN_DIR_LOGS:-/config/logs}"
export SPOOLMAN_DIR_BACKUPS="${SPOOLMAN_DIR_BACKUPS:-/config/backups}"
export SPOOLMAN_HOST="${SPOOLMAN_HOST:-0.0.0.0}"

# Kubernetes service links can set SPOOLMAN_PORT to tcp://ip:port. Ignore them, as the upstream entrypoint does.
case "${SPOOLMAN_PORT:-8000}" in
  *://*) SPOOLMAN_PORT=8000 ;;
esac
export SPOOLMAN_PORT="${SPOOLMAN_PORT:-8000}"

cd /app/spoolman
exec /app/venv/bin/uvicorn spoolman.main:app --host "${SPOOLMAN_HOST}" --port "${SPOOLMAN_PORT}"
