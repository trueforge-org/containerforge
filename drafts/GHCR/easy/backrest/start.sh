#!/usr/bin/env bash
set -euo pipefail

# Backrest keeps its config and data under /config. Caches go to /tmp.
export HOME=/config
export XDG_CONFIG_HOME=/config/.config
export XDG_DATA_HOME=/config/.local/share
export RESTIC_CACHE_DIR=/tmp/restic-cache

mkdir -p /config/.config/backrest /config/.local/share/backrest /tmp/restic-cache
cd /config

# Backrest binds to localhost by default. Bind all interfaces so other containers can reach it.
# The TrueCharts chart sets BACKREST_PORT=0.0.0.0:9898.
export BACKREST_PORT="${BACKREST_PORT:-0.0.0.0:9898}"
exec /app/backrest/backrest
