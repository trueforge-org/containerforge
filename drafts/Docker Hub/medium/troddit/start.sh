#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-3000}"
# Bind all interfaces explicitly, so the container hostname does not decide the Next bind address.
export HOSTNAME="0.0.0.0"
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1

# The app keeps no state in /config, so an empty /config needs no seeding.
cd /app/troddit
exec node server.js "$@"
