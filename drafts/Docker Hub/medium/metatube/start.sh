#!/usr/bin/env bash
set -euo pipefail

# State lives in /config (SQLite database, migrations). Media output goes to /downloads.
mkdir -p /config /config/migrations /downloads

export PORT="${PORT:-5000}"
export HOST="${HOST:-0.0.0.0}"
export DATABASE_URL="${DATABASE_URL:-sqlite:////config/app.db}"
export DOWNLOADS="${DOWNLOADS:-/downloads}"
export FFMPEG="${FFMPEG:-/usr/bin}"

cd /app/metatube
# UNVERIFIED: the entrypoint module. Upstream runs config/metatube.py; confirm the file and [project.scripts] at the pinned commit.
exec /app/venv/bin/python metatube.py
