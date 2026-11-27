#!/usr/bin/env bash
set -eu

# Clips live under /config. The app's hardcoded /app/app/static/media is a symlink to /config/media.
mkdir -p /config/media/videos /config/media/images

if [ -z "${PLEX_URL:-}" ] || [ -z "${PLEX_TOKEN:-}" ]; then
  echo "[clipplex] WARNING: PLEX_URL or PLEX_TOKEN is not set. The UI loads, but clip creation will fail." >&2
fi

export FLASK_APP=main.py PYTHONDONTWRITEBYTECODE=1 TMPDIR=/tmp

# Module paths in the app are relative to /app
cd /app

# Flask development server, as upstream runs it. Secrets stay in the environment.
exec /app/venv/bin/python -m flask run --host 0.0.0.0 --port 5000
