#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Map data, styles and fonts are supplied by the user in /config. Nothing is seeded.
cd /config

export TILESERVER_GL_ALLOWED_HOSTS="${TILESERVER_GL_ALLOWED_HOSTS:-*}"

# Virtual display for server-side rendering, as the upstream entrypoint does.
export DISPLAY=:99
rm -f /tmp/.X99-lock
Xvfb "${DISPLAY}" -nolisten unix >/dev/null 2>&1 &

# The port defaults to 8080. Do not pass --port in Docker (upstream docs say it makes the container look unhealthy).
exec node /app/tileserver-gl/node_modules/tileserver-gl/src/main.js \
  --bind 0.0.0.0
