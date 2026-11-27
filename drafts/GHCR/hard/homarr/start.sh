#!/usr/bin/env bash
set -euo pipefail

# Persistent state: SQLite database under /config (DB_URL in the Dockerfile).
mkdir -p /config/db

# Bundled Redis: ephemeral (no persistence), localhost only, state in /tmp.
mkdir -p /tmp/redis
redis-server \
    --dir /tmp/redis \
    --save "" \
    --appendonly no \
    --bind 127.0.0.1 \
    --port 6379 \
    --pidfile /tmp/redis/redis.pid \
    --daemonize yes

# UNVERIFIED: the upstream scripts/run.sh (not read) renders nginx.conf and may
# generate AUTH_SECRET with openssl. Neither step is reproduced here yet.
# UNVERIFIED: standalone Next.js server entry point and env names (PORT, HOSTNAME).
# UNVERIFIED: Next.js writes .next/cache under /app, which is read-only at runtime.
cd /app/homarr
export PORT=7575
export HOSTNAME=0.0.0.0
exec node /app/homarr/server.js
