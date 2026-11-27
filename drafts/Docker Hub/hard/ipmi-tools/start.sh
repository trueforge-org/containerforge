#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Persist a generated secret key in /config so sessions survive restarts. Never print it.
if [ -z "${SECRET_KEY:-}" ]; then
  if [ ! -s /config/secret_key ]; then
    umask 077
    /app/venv/bin/python -c 'import secrets; print(secrets.token_hex(32))' > /config/secret_key
  fi
  SECRET_KEY="$(cat /config/secret_key)"
  export SECRET_KEY
fi

# Run gunicorn, not main.py: main.py forces debug=True. main:app works because main.py imports `app` at module level.
# UNVERIFIED: that import path. Confirm on the first run.
cd /app/bin
exec /app/venv/bin/gunicorn \
  --bind "0.0.0.0:${PORT:-5000}" \
  --workers 1 \
  --threads 4 \
  main:app
