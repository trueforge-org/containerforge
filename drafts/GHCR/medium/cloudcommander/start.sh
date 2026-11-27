#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

export HOME=/config
export PORT="${PORT:-8000}"
# UNVERIFIED: IP and PORT env bindings, to be confirmed with an outside-container probe (0.0.0.0 by default)
export IP="${IP:-0.0.0.0}"
export cloudcmd_root="${cloudcmd_root:-/config}"
export cloudcmd_auth="${cloudcmd_auth:-true}"
export cloudcmd_open="${cloudcmd_open:-false}"
export cloudcmd_terminal="${cloudcmd_terminal:-false}"

cd /config
exec /app/cloudcommander/node_modules/.bin/cloudcmd
