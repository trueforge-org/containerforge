#!/usr/bin/env bash
set -euo pipefail

# Seed the user directory only when files are missing or empty, so user flows are kept.
mkdir -p /config
if [ ! -s /config/settings.js ]; then
    cp /defaults/settings.js /config/settings.js
fi
if [ ! -s /config/flows.json ]; then
    cp /defaults/flows.json /config/flows.json
fi

cd /config
# UNVERIFIED: entry file red.js and --userDir flag follow the npm bin field and upstream docs; confirm on first run.
exec node /app/node_modules/node-red/red.js --userDir /config
