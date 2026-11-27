#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/files

# Seed the config only when missing; never overwrite user edits.
if [[ ! -f /config/quickshare.yml ]]; then
  cp /defaults/quickshare.yml /config/quickshare.yml
fi

# Avoid the interactive admin-name prompt on first run. The app reads the rest from the environment.
export DEFAULTADMIN="${DEFAULTADMIN:-admin}"

cd /config
exec /app/quickshare -c /config/quickshare.yml
