#!/usr/bin/env bash
set -euo pipefail

# Seed /config/venv from the prebuilt /app/venv only when it is missing or empty. /app stays read-only.
if [ ! -d /config/venv ] || [ -z "$(ls -A /config/venv 2>/dev/null)" ]; then
    echo "[start.sh] Seeding /config/venv from /app/venv"
    rm -rf /config/venv
    mkdir -p /config
    cp -R /app/venv /config/venv
fi

mkdir -p /config/data

# UNVERIFIED: how TOKEN, OWNER, PREFIX and STORAGE_TYPE reach Red 3.5.24. Pass TOKEN through the environment only,
# never on the command line (process list). UNVERIFIED: the instance name and the --data-path flag.
exec /config/venv/bin/redbot red --data-path /config/data
