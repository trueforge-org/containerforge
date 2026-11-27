#!/usr/bin/env bash

export TRAGGO_DATABASE_CONNECTION="${TRAGGO_DATABASE_CONNECTION:-/config/traggo.db}"
export TRAGGO_PORT="${TRAGGO_PORT:-3030}"

mkdir -p "$(dirname "${TRAGGO_DATABASE_CONNECTION}")"
cd /config || exit 1
exec /app/traggo
