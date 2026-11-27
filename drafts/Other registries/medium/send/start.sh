#!/usr/bin/env bash

mkdir -p /config

export FILE_DIR="${FILE_DIR:-/config/uploads}"
mkdir -p "${FILE_DIR}"
export PORT="${PORT:-1443}"
export REDIS_HOST="${REDIS_HOST:-valkey}"
export REDIS_PORT="${REDIS_PORT:-6379}"

cd /app/send || exit 1
exec node server/bin/prod.js
