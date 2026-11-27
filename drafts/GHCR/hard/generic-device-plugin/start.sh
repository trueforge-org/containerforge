#!/usr/bin/env bash

DOMAIN="${DOMAIN:-truecharts.org}"
LISTEN="${LISTEN:-0.0.0.0:8080}"
LOG_LEVEL="${LOG_LEVEL:-info}"
PLUGIN_DIR="${PLUGIN_DIR:-/tmp/device-plugins}"

mkdir -p "${PLUGIN_DIR}"

# --device specs are passed through as arguments ("$@")
exec /app/generic-device-plugin/generic-device-plugin \
  --domain "${DOMAIN}" \
  --listen "${LISTEN}" \
  --log-level "${LOG_LEVEL}" \
  --plugin-directory "${PLUGIN_DIR}" \
  "$@"
