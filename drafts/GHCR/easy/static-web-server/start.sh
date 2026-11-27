#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/public

# Seed a placeholder page only when the web root has no index.html. Never overwrite existing content.
if [ ! -f /config/public/index.html ]; then
    cp /defaults/index.html /config/public/index.html
fi

# The binary reads SERVER_* from the environment. These defaults match settings.yaml.
export SERVER_HOST="${SERVER_HOST:-0.0.0.0}"
export SERVER_PORT="${SERVER_PORT:-8080}"
export SERVER_ROOT="${SERVER_ROOT:-/config/public}"
export SERVER_LOG_LEVEL="${SERVER_LOG_LEVEL:-error}"

cd /app
exec /app/static-web-server
