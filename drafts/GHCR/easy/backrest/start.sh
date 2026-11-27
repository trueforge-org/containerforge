#!/usr/bin/env bash
set -euo pipefail

# Backrest keeps its config and data under /config. Caches go to /tmp.
export HOME=/config
export XDG_CONFIG_HOME=/config/.config
export XDG_DATA_HOME=/config/.local/share
export RESTIC_CACHE_DIR=/tmp/restic-cache

mkdir -p /config/.config/backrest /config/.local/share/backrest /tmp/restic-cache
cd /config

# UNVERIFIED: the listen address. Backrest must bind 0.0.0.0:9898 to be reachable from other containers.
# The TrueCharts chart sets BACKREST_PORT=0.0.0.0:9898, but this is not confirmed upstream.
# Confirm with the probe, and add the verified setting here if it binds to localhost only.
exec /app/backrest/backrest
