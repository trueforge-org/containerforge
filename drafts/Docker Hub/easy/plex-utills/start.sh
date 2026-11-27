#!/usr/bin/env bash
set -euo pipefail

# First-run dirs. /logs and app/static/img/tmp are symlinks created at build time.
mkdir -p /config/logs /config/backup /tmp/pu-img-tmp

# App opens app/static/default_db/... and ./version relatively.
cd /app/plex-utills

# Upstream nginx is dropped; Flask serves /static itself.
# One worker: the app starts a scheduler and opens the SQLite DB at import time.
exec /usr/local/bin/gunicorn --chdir /app/plex-utills main:app \
  -w 1 --threads "${GUNICORN_THREADS:-4}" -b 0.0.0.0:5000 \
  --worker-tmp-dir /tmp --access-logfile -
