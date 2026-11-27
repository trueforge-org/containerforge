#!/usr/bin/env bash
set -euo pipefail

cd /app/cryptpad

# Runtime state lives in /config. The build already ran the frontend build, so start.sh does not run it again.
mkdir -p /config/config /config/blob /config/block /config/customize /config/data /config/datastore

# Seed config only when missing. Never overwrite operator edits.
# UNVERIFIED: the example file paths at the chosen tag.
if [ ! -s /config/config/config.js ]; then
    cp /app/cryptpad/config.default/config.example.js /config/config/config.js
fi
if [ ! -s /config/config/infra.js ]; then
    cp /app/cryptpad/config.default/infra.example.js /config/config/infra.js
fi

# exec so the server receives signals.
# UNVERIFIED: that the server binds 0.0.0.0:3000 and that `npm start` forwards signals.
exec npm start
