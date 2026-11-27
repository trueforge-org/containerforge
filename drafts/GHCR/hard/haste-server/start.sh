#!/usr/bin/env bash
set -euo pipefail

# Config lives in /config. Only seed it when missing or empty, so user edits are kept.
CONFIG_FILE="/config/config.js"
mkdir -p /config/data

if [[ ! -s "${CONFIG_FILE}" ]]; then
    cp /defaults/config.js "${CONFIG_FILE}"
fi

export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-7777}"

cd /app/haste-server
# server.js takes the config path as argv[2]. /app stays read-only.
exec node server.js "${CONFIG_FILE}"
