#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-3000}"
export TZ="${TZ:-Etc/UTC}"

# /app/dumbassets/data is a symlink to /config, so the JSON files, Images/, Receipts/ and Manuals/ live there.
mkdir -p /config/Images /config/Receipts /config/Manuals

# Persist a random session secret so sessions survive restarts and the upstream default is never used.
# An explicit SESSION_SECRET from the environment always wins.
if [ -z "${SESSION_SECRET:-}" ]; then
  if [ ! -s /config/.session_secret ]; then
    umask 077
    head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /config/.session_secret
  fi
  SESSION_SECRET="$(cat /config/.session_secret)"
  export SESSION_SECRET
fi

# UNVERIFIED: the upstream CMD is npm start. This runs node server.js directly, which assumes npm start does the same.
cd /app/dumbassets
exec node server.js
