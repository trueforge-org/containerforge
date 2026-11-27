#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: upload and log directory env names; point them at /config once confirmed from source
mkdir -p /config/upload /config/log

export SERVER_PORT="${SERVER_PORT:-8080}"

# UNVERIFIED: wait-and-retry for PostgreSQL (the backend exits without it); decide after reading source
cd /app/gamevault-backend
exec node dist/src/main.js
