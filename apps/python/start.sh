#!/usr/bin/env bash
set -euo pipefail

if [ -d /apps/venv ] && { [ ! -d /config/venv ] || [ -z "$(ls -A /config/venv 2>/dev/null)" ]; }; then
    echo "[start.sh] Restoring prebuilt venv to /config/venv"
    rm -rf /config/venv
    mkdir -p /config
    cp -R /apps/venv /config/venv
fi

exec "$@"
