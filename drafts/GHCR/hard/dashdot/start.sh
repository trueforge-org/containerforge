#!/usr/bin/env bash
# Initial draft. The app writes nothing at runtime, so an empty /config needs no seeding.

export DASHDOT_PORT="${DASHDOT_PORT:-3001}"

cd /app/dashdot || exit 1
exec node server/dist/index.cjs
