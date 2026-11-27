#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives under /config (HOME=/config, so ~/.affine is /config/.affine). Caches go to /tmp.
# Create the folders only when missing; never overwrite existing files.
mkdir -p /config/.affine/config /config/.affine/storage

# Defaults match the TrueCharts chart and the sibling postgresql and valkey apps (UNVERIFIED for valkey).
export POSTGRES_HOST="${POSTGRES_HOST:-postgresql}"
export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export POSTGRES_DB="${POSTGRES_DB:-affine}"
export POSTGRES_USER="${POSTGRES_USER:-affine}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set}"

# Build DATABASE_URL on every start, so a changed password also applies to existing data.
# The password is URL-encoded by node and read from the environment, not from the command line.
ENCODED_PASSWORD="$(node -e 'process.stdout.write(encodeURIComponent(process.env.POSTGRES_PASSWORD))')"
export DATABASE_URL="postgresql://${POSTGRES_USER}:${ENCODED_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

export PORT="${PORT:-3010}"
export NODE_ENV="${NODE_ENV:-production}"

# Valkey is optional; UNVERIFIED how the server behaves when REDIS_SERVER_HOST is unreachable.
export REDIS_SERVER_HOST="${REDIS_SERVER_HOST:-valkey}"
export REDIS_SERVER_PORT="${REDIS_SERVER_PORT:-6379}"

cd /app || exit 1

# Run the migration before the server starts; a failure stops the start.
# UNVERIFIED: the predeploy script path inside the upstream server bundle.
node ./scripts/self-host-predeploy.js

# UNVERIFIED: the server binds all interfaces by default; check from outside the container.
exec node ./dist/main.js
