#!/usr/bin/env bash
set -euo pipefail

CONFIG="/config/nntp2nntp.conf"
mkdir -p /config/logs /config/keys

# Seed the default config only when it is missing or empty
if [[ ! -s "${CONFIG}" ]]; then
    cp /defaults/nntp2nntp.conf "${CONFIG}"
fi

# UNVERIFIED: installed script name (setup.py lists nntp2nntp.py under scripts)
exec /app/venv/bin/nntp2nntp.py "${CONFIG}"
