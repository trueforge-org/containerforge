#!/usr/bin/env bash
set -euo pipefail

# Persistent path required by settings.yaml. Only create it when missing.
mkdir -p /config

if [[ -z "${CHROMIUM_EXECUTABLE_PATH:-}" && -x /usr/bin/chromium ]]; then
  export CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium
fi

# /app is read-only at runtime. The server only reads from it.
cd /app

# UNVERIFIED: confirm "start" is the script name in package.json. Upstream CMD is npm run start.
exec npm run start
