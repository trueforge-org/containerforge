#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-3000}"
export DATABASE_PATH="${DATABASE_PATH:-/config}"
export SECRETKEY_PATH="${SECRETKEY_PATH:-/config/secrets}"
export LOG_PATH="${LOG_PATH:-/config/logs}"
export BLOB_STORAGE_PATH="${BLOB_STORAGE_PATH:-/config/storage}"

# Create missing directories only. Nothing is seeded, and nothing is written under /app.
mkdir -p "$DATABASE_PATH" "$SECRETKEY_PATH" "$LOG_PATH" "$BLOB_STORAGE_PATH"

# UNVERIFIED: the server binds 0.0.0.0 by default. Confirm from outside the container.
cd /config
exec /app/flowise/node_modules/.bin/flowise start
