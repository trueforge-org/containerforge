#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"
export DATABASE_URL="${DATABASE_URL:-sqlite:////config/app.db}"
export FLASK_APP=emby-sync.py

mkdir -p /config

if [ -z "${EMBY_SERVER:-}" ] || [ -z "${SECRET_KEY:-}" ]; then
  echo "[start.sh] WARNING: EMBY_SERVER and/or SECRET_KEY are not set; the app will start but cannot talk to Emby." >&2
fi

# upstream boot.sh uses a relative venv/, so run from the app directory and use the base venv explicitly
cd /app/emby-sync
/app/venv/bin/flask db upgrade
exec /app/venv/bin/gunicorn -b 0.0.0.0:5000 \
  --access-logfile - --error-logfile - emby-sync:app
