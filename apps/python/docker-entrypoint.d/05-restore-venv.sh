#!/usr/bin/env bash
set -euo pipefail

if [ -d /defaults/venv ] && [ ! -L "${VENV_FOLDER}" ] && { [ ! -d "${VENV_FOLDER}" ] || [ -z "$(ls -A "${VENV_FOLDER}" 2>/dev/null)" ]; }; then
    echo "[05-restore-venv] Restoring prebuilt venv to ${VENV_FOLDER}"
    if [ -d "${VENV_FOLDER}" ]; then
        rm -rf "${VENV_FOLDER}"
    fi
    mkdir -p "$(dirname "${VENV_FOLDER}")"
    cp -R /defaults/venv "${VENV_FOLDER}"
fi
