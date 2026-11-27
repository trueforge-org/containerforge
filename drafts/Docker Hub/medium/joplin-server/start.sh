#!/usr/bin/env bash

export APP_PORT="${APP_PORT:-22300}"
export NODE_ENV="${NODE_ENV:-production}"

# Scratch and caches go to /tmp; nothing is written to /app.
export TMPDIR="${TMPDIR:-/tmp}"
export YARN_CACHE_FOLDER="${YARN_CACHE_FOLDER:-/tmp/yarn-cache}"

# UNVERIFIED: the upstream image runs under pm2 with a writable PM2_HOME; this plan runs yarn directly.
# UNVERIFIED: whether the server writes any file at runtime; if it does, point it at /config or /tmp.
cd /app/joplin/packages/server
exec yarn start-prod
