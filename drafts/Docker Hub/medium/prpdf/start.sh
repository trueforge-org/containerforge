#!/usr/bin/env bash
set -eu

export WORKDIR="${WORKDIR:-/app/prpdf}"
export FLASK_APP="${FLASK_APP:-prpdf.py}"
export FLASK_RUN_HOST="${FLASK_RUN_HOST:-0.0.0.0}"
export FLASK_RUN_PORT="${FLASK_RUN_PORT:-5000}"

# UNVERIFIED: output and archive folder names. Upstream uses /source/static/pdf and /Archiv (per the chart).
# Confirm against prpdf.py before relying on these paths. Only create missing directories, never overwrite.
mkdir -p /config/static/pdf /config/Archiv

# /app is read-only at runtime, so run from the app folder without writing into it.
cd "${WORKDIR}"

exec /app/venv/bin/flask run \
    --host="${FLASK_RUN_HOST}" \
    --port="${FLASK_RUN_PORT}"
