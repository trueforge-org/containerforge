#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/mosquitto/config/mosquitto.conf"

# Use the default config when none is mounted
if [[ ! -s "${CONFIG_FILE}" ]]; then
    CONFIG_FILE="/defaults/mosquitto.conf"
fi

if [[ "${1:-}" == "/start.sh" ]]; then
    shift
fi

exec mosquitto -c "${CONFIG_FILE}" "$@"
