#!/usr/bin/env bash
set -euo pipefail

# jdb.py reads and writes ./data/db.json relative to the working directory,
# so run from /config. The app seeds db.json itself on first use.
mkdir -p /config/data
cd /config

exec uwsgi \
  --http "0.0.0.0:${SHORTIPY_PORT:-4321}" \
  --pythonpath /app/shortipy \
  --wsgi-file /app/shortipy/shorti.py \
  --callable app \
  --master \
  --processes "${SHORTIPY_PROCESSES:-1}" \
  --threads "${SHORTIPY_THREADS:-1}" \
  --vacuum \
  --die-on-term \
  --need-app
