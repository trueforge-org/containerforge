#!/bin/sh
# Initial draft startup for website-shot (Nuxt 2 server). Runs as the apps user.
# /app is read-only at runtime; screenshots go to /config via a symlink created at build time.
set -eu

mkdir -p /config/screenshots /tmp/website-shot

export HOME=/tmp
export NUXT_HOST="${NUXT_HOST:-0.0.0.0}"
export NUXT_PORT="${NUXT_PORT:-3000}"
export PASSWORD_PROTECT="${PASSWORD_PROTECT:-0}"
export PASSWORD="${PASSWORD:-admin}"
export RUNNING_DOCKER=1

cd /app/website-shot

# Run the Nuxt binary directly so yarn does not write anything and signals reach Nuxt.
exec ./node_modules/.bin/nuxt start
