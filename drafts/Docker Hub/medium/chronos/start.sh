#!/usr/bin/env bash
set -euo pipefail

export CHRONOS_PATH="${CHRONOS_PATH:-/config}"
export PIP_CACHE_DIR=/tmp/pip
export TMPDIR=/tmp

mkdir -p "$CHRONOS_PATH/logs" "$CHRONOS_PATH/scripts"

# The app creates chronos.db itself. alembic.ini is resolved from the working directory.
cd /app/chronos
exec /app/venv/bin/python chronos.py
