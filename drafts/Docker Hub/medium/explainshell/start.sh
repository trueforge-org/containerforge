#!/usr/bin/env bash
set -euo pipefail

export DEBUG="${DEBUG:-false}"
export DB_PATH="${DB_PATH:-/app/explainshell.db}"

# a user-supplied database in /config takes precedence over the baked one
if [[ -s /config/explainshell.db ]]; then
  export DB_PATH=/config/explainshell.db
fi

cd /app/explainshell-src
# UNVERIFIED: gunicorn binds directly to the network here; upstream put Caddy in front on localhost
exec /app/venv/bin/gunicorn \
  -w "${GUNICORN_WORKERS:-2}" --threads "${GUNICORN_THREADS:-4}" \
  --timeout 15 --graceful-timeout 5 \
  --max-requests 10000 --max-requests-jitter 2000 --preload \
  --worker-tmp-dir /tmp \
  -b 0.0.0.0:8080 \
  "explainshell.web:create_app()"
