#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives under /config. /app is read-only at runtime.
mkdir -p /config

# Seed settings.json only when missing. Existing user state is never overwritten.
if [ ! -s /config/settings.json ]; then
  cp /app/etherpad/settings.json.dist /config/settings.json
fi

# UNVERIFIED: the server entry file, the --settings flag and the var/ write location for the packaged 3.3.22 layout.
# The upstream image runs: cd src && node --require tsx/cjs node/server.ts
cd /app/etherpad/src
exec node --require tsx/cjs node/server.ts --settings /config/settings.json
