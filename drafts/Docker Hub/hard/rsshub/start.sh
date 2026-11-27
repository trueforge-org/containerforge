#!/usr/bin/env bash
set -eu

# Defaults match settings.yaml. CACHE_TYPE uses ${VAR-default} so an empty value (cache disabled) is kept.
export PORT="${PORT:-1200}"
export LISTEN_INADDR_ANY="${LISTEN_INADDR_ANY:-1}"
export CACHE_TYPE="${CACHE_TYPE-memory}"
export LOGGER_LEVEL="${LOGGER_LEVEL:-info}"

mkdir -p /tmp/.npm
cd /app

# UNVERIFIED: npm forwards signals to the server; an exec of the node entry from package.json "start" would avoid the npm layer.
exec npm run start
