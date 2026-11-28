#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: upload and log directory env names; point them at /config once confirmed from source
# Env names from the TrueCharts chart; defaults keep all writes under /config.
export VOLUMES_FILES="${VOLUMES_FILES:-/config/files}"
export VOLUMES_IMAGES="${VOLUMES_IMAGES:-/config/media}"
export VOLUMES_LOG="${VOLUMES_LOG:-/config/logs}"
export DB_SYSTEM="${DB_SYSTEM:-POSTGRESQL}"
export DB_PORT="${DB_PORT:-5432}"
export DB_DATABASE="${DB_DATABASE:-gamevault}"
export DB_USERNAME="${DB_USERNAME:-gamevault}"
mkdir -p "${VOLUMES_FILES}" "${VOLUMES_IMAGES}" "${VOLUMES_LOG}"

export SERVER_PORT="${SERVER_PORT:-8080}"

# UNVERIFIED: wait-and-retry for PostgreSQL (the backend exits without it); decide after reading source
cd /app/gamevault-backend
exec node dist/src/main.js
