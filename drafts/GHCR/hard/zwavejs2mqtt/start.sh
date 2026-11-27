#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. The store (settings, keys, backups) lives in /config.
export STORE_DIR="${STORE_DIR:-/config/store}"
export PORT="${PORT:-8091}"
mkdir -p "${STORE_DIR}"

# UNVERIFIED: entry point path is taken from the upstream Dockerfile CMD; confirm after extraction.
cd /app/zwave-js-ui
exec node server/bin/www
