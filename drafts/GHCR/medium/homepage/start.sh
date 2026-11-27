#!/usr/bin/env bash
set -eu

# persistent state lives in /config (the /app/config symlink points there)
mkdir -p /config/logs

# target of the /app/.next/cache symlink, must exist at runtime
mkdir -p /tmp/next-cache

# upstream creates a default YAML on first start (UNVERIFIED for v2.8.0; check with an empty /config).
# If it does not, seed the upstream sample configs with cp -n only when missing.

export HOSTNAME="${HOSTNAME:-0.0.0.0}"
export PORT="${PORT:-3000}"
export HOMEPAGE_ALLOWED_HOSTS="${HOMEPAGE_ALLOWED_HOSTS:-localhost}"
export HOMEPAGE_BUILDTIME="${HOMEPAGE_BUILDTIME:-$(date +%s)}"

cd /app
exec node server.js
