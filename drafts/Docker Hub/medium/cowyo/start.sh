#!/usr/bin/env bash

export SQLITE_PATH="${SQLITE_PATH:-/config/cowyo2.sqlite3}"
mkdir -p "$(dirname "${SQLITE_PATH}")"

cd /config
# UNVERIFIED: bind address (must be all interfaces) and whether the default port is 8001 in this build.
exec /app/cowyo/cowyo
