#!/usr/bin/env bash
set -euo pipefail

export HOME=/tmp

mkdir -p /config/user-data /config/item-icons

# Seed the default config only when missing, so saved user config is never overwritten.
# UNVERIFIED: whether the server needs this file to start; drop the seed if it does not.
if [[ ! -f /config/user-data/conf.yml && -f /defaults/conf.yml ]]; then
    cp /defaults/conf.yml /config/user-data/conf.yml
fi

cd /app/dashy
exec node server.js
