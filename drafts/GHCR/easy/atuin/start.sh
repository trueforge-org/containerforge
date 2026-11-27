#!/usr/bin/env bash
set -euo pipefail

export ATUIN_CONFIG_DIR=/config
export RUST_LOG="${RUST_LOG:-atuin_server=info}"
export TZ="${TZ:-Etc/UTC}"

mkdir -p "${ATUIN_CONFIG_DIR}"

if [ -z "${ATUIN_DB_URI:-}" ]; then
  echo "Error: ATUIN_DB_URI is required (PostgreSQL connection URL)." >&2
  exit 1
fi

# UNVERIFIED: bind-address variable name (ATUIN_HOST assumed) and default; confirm against atuin-server settings before merge.
export ATUIN_HOST="${ATUIN_HOST:-0.0.0.0}"
export ATUIN_PORT="${ATUIN_PORT:-8888}"

cd /app/atuin
# UNVERIFIED: the 'start' subcommand; if atuin-server takes none, drop it.
exec /app/atuin/atuin-server start
