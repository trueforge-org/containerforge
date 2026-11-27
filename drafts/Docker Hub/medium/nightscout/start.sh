#!/usr/bin/env bash
set -euo pipefail

# API_SECRET and MONGO_CONNECTION are required. Refuse to start without them. Never print their values.
if [ -z "${API_SECRET:-}" ] || [ -z "${MONGO_CONNECTION:-}" ]; then
    echo "API_SECRET and MONGO_CONNECTION must be set" >&2
    exit 1
fi

# The server binds all interfaces unless NIGHTSCOUT_HOSTNAME is set (upstream README).
cd /app/nightscout
exec node lib/server/server.js
