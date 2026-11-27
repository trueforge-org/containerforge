#!/usr/bin/env bash
set -euo pipefail

# Stateless app: nothing is written to /config or /app.
# PORT default 3000 (UNVERIFIED against index.js).
export PORT="${PORT:-3000}"

cd /app/docker-hub-rss
echo "Starting docker-hub-rss on port ${PORT}"
exec node index.js
