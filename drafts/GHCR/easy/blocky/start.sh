#!/usr/bin/env bash
set -euo pipefail

config_file="${BLOCKY_CONFIG_FILE:-/config/config.yml}"

mkdir -p "$(dirname "${config_file}")" /tmp/blocky-cache

# Seed the config only when it is missing or empty, so user changes are kept.
if [ ! -s "${config_file}" ]; then
    cp /defaults/config.yml "${config_file}"
fi

exec /app/blocky
