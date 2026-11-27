#!/usr/bin/env bash

# UNVERIFIED: commento does not retry the database connection itself. A wait-for-postgresql loop may be needed.
export COMMENTO_BIND_ADDRESS="${COMMENTO_BIND_ADDRESS:-0.0.0.0}"
export COMMENTO_PORT="${COMMENTO_PORT:-8080}"

cd /app/commento
exec /app/commento/commento
