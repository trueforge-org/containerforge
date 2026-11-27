#!/usr/bin/env bash
set -euo pipefail

# Config-file mode when a non-empty config exists; otherwise env mode (FRITZ_* vars).
# OPEN DECISION (plan section 10): without credentials the exporter exits 1.
# The protocol needs the image to start without env vars, so this is not settled yet.
CONFIG_FILE="${FRITZ_CONFIG_FILE:-/config/config.yaml}"

if [ ! -f /config/config.example.yaml ]; then
  cp /defaults/config.example.yaml /config/config.example.yaml
fi

if [ -s "${CONFIG_FILE}" ]; then
  echo "Using config file ${CONFIG_FILE}"
  exec /app/venv/bin/python -m fritzexporter --config "${CONFIG_FILE}" "$@"
fi

if [ -z "${FRITZ_USERNAME:-}" ] || { [ -z "${FRITZ_PASSWORD:-}" ] && [ -z "${FRITZ_PASSWORD_FILE:-}" ]; }; then
  echo "No ${CONFIG_FILE} and no FRITZ_USERNAME/FRITZ_PASSWORD(_FILE): the exporter will refuse to start." >&2
fi

exec /app/venv/bin/python -m fritzexporter "$@"
