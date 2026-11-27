#!/usr/bin/env bash
set -euo pipefail

# Data lives in /config (persistent). The app and its venv stay read-only in /app.
export HOME=/config
export TIMETAGGER_BIND="${TIMETAGGER_BIND:-0.0.0.0:8080}"
export TIMETAGGER_DATADIR="${TIMETAGGER_DATADIR:-/config/timetagger}"

mkdir -p "${TIMETAGGER_DATADIR}"

cd /app
exec /app/venv/bin/python -m timetagger
