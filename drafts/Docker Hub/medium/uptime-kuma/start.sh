#!/usr/bin/env bash
set -eu

mkdir -p /config

cd /app/uptime-kuma
# Nothing is seeded. The SQLite database is created under the data directory (/config via symlink) on first run.
exec node server/server.js
