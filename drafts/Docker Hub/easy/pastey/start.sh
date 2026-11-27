#!/usr/bin/env bash
set -euo pipefail

export PASTEY_DATA_DIRECTORY="${PASTEY_DATA_DIRECTORY:-/config/data}"
export PASTEY_LISTEN_ADDRESS="${PASTEY_LISTEN_ADDRESS:-0.0.0.0}"

# Seed only the data directory on /config; nothing is written under /app.
mkdir -p "${PASTEY_DATA_DIRECTORY}"

# app.py imports the pastey package relative to the working directory.
cd /app/pastey
exec /usr/local/bin/python app.py
