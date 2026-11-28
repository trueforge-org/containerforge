#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${GATUS_CONFIG_PATH:-/config/config.yaml}"

mkdir -p /config/data "$(dirname "${CONFIG_FILE}")"

# seed the default config only when missing or empty; never overwrite user config
if [[ ! -s "${CONFIG_FILE}" ]]; then
    echo "Seeding default config to ${CONFIG_FILE}"
    cp /defaults/config.yaml "${CONFIG_FILE}"
fi

export GATUS_CONFIG_PATH="${CONFIG_FILE}"
exec /app/gatus/gatus
