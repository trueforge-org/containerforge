#!/usr/bin/env bash

# The app writes CSS/JS bundles and symlinks into STATIC_FOLDER/build at import time.
# /app is read-only at runtime, so the static tree is copied to /tmp (ephemeral) on start.
STATIC_DIR=/tmp/whoogle/static
mkdir -p /config "${STATIC_DIR}"
if [ ! -f "${STATIC_DIR}/settings/languages.json" ]; then
  cp -r /app/whoogle/app/static/. "${STATIC_DIR}/"
fi

export APP_ROOT=/app/whoogle/app
export STATIC_FOLDER="${STATIC_DIR}"
export CONFIG_VOLUME=/config

cd /app/whoogle || exit 1
exec python3 -um app \
    --host "${ADDRESS:-0.0.0.0}" \
    --port "${PORT:-${EXPOSE_PORT:-5000}}"
