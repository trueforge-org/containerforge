#!/bin/bash
set -euo pipefail

PORT="${PORT:-5000}"
NODE_ENV="${NODE_ENV:-production}"

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

# Persistent data lives in /config. The app's data/ path is a symlink to /config/data (set in the Dockerfile).
mkdir -p /config/data

export PORT NODE_ENV

cd /app/snippet-box
echo "Starting snippet-box on port ${PORT}"
exec node build/server.js "$@"
