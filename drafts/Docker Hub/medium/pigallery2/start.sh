#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/config /config/db /config/images
if [ ! -s /config/config/config.json ]; then
    cp /defaults/config.json /config/config/config.json
fi

cd /app/pigallery2
exec node --expose-gc ./src/backend/index --config-path=/config/config/config.json
