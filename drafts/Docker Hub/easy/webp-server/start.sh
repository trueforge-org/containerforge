#!/usr/bin/env bash
set -euo pipefail

# Seed the JSON config only when it is missing or empty. Never overwrite user state.
if [ ! -s /config/config.json ]; then
  cp /defaults/config.json /config/config.json
fi

# WEBP_* env vars override the file on every start. The host must be 0.0.0.0 for other containers.
export WEBP_HOST="${WEBP_HOST:-0.0.0.0}"
export WEBP_IMG_PATH="${WEBP_IMG_PATH:-/opt/pics}"
export WEBP_EXHAUST_PATH="${WEBP_EXHAUST_PATH:-/tmp/exhaust}"
mkdir -p "${WEBP_EXHAUST_PATH}" /tmp/metadata

exec /app/webp-server --config /config/config.json --verbosity "${LOG_VERBOSITY:-3}"
