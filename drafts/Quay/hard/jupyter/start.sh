#!/usr/bin/env bash
set -euo pipefail

# All state lives in /config. Create the directories only when missing, so an empty /config starts cleanly.
mkdir -p /config/.jupyter /config/.local/share/jupyter /config/work

# Listen on all interfaces so other containers can reach the server.
# Jupyter generates an access token on first start and prints it in the log (upstream default).
exec /app/venv/bin/jupyter lab \
  --ip=0.0.0.0 \
  --port="${JUPYTER_PORT:-8888}" \
  --no-browser \
  --ServerApp.root_dir=/config/work
