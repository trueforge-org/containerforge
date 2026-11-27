#!/usr/bin/env bash

mkdir -p /config

export FLASK_PORT="${FLASK_PORT:-8084}"
export INGEST_DIR="${INGEST_DIR:-/books}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

cd /app/shelfmark || exit 1
# UNVERIFIED: module entry point. Check pyproject.toml [project.scripts] or the
# upstream entrypoint.sh at this tag before merging. Bind address must be 0.0.0.0.
exec /app/shelfmark/.venv/bin/python -m shelfmark
