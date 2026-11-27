#!/bin/sh
set -eu

# Idempotent: only creates directories, seeds nothing. The assets directory is
# populated by the user, as upstream requires.
mkdir -p /config/config /config/assets

export CONFIG="${CONFIG:-/config/config}"
export DATA="${DATA:-/config/assets}"
export GIN_MODE="${GIN_MODE:-release}"

cd /app/hammond
echo "Starting hammond with CONFIG=${CONFIG} DATA=${DATA}"
# Gin listens on :3000 (all interfaces); the port is hard-coded in server/main.go.
exec ./app
