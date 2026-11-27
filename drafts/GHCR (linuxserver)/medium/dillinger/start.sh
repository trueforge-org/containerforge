#!/usr/bin/env bash

# seed /config/configs from the image defaults, only when missing; never overwrite user config
if [[ ! -d /config/configs ]]; then
  mkdir -p /config/configs
  cp -a /usr/share/dillinger-defaults/configs/. /config/configs/
fi

PORT="${PORT:-8080}"
BIND_ADDRESS="${BIND_ADDRESS:-0.0.0.0}"
export PORT BIND_ADDRESS NODE_ENV="${NODE_ENV:-production}"

cd /app/dillinger || exit 1
# UNVERIFIED: launch command for v3.39.1 (package.json start script), confirm on the build
exec node app.js
