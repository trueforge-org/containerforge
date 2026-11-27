#!/usr/bin/env bash

# /app is read-only at runtime. Persistent state goes to /config/volume, caches to /tmp.
mkdir -p /config/volume
mkdir -p /tmp/npm-cache
export npm_config_cache=/tmp/npm-cache
export NODE_OPTIONS="${NODE_OPTIONS:---dns-result-order=ipv4first}"

cd /app/server || exit 1

# UNVERIFIED: the direct bin is used instead of "npm exec" so the server is PID 1 and gets signals.
# UNVERIFIED: the server binds 0.0.0.0 by default; check with a probe from outside the container.
exec /app/server/node_modules/.bin/scrypted-serve
