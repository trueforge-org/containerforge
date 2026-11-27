#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. Gateway state (database, config) lives in /config.
export DECONZ_APPDATA_DIR=/config
mkdir -p /config

web_port="${DECONZ_WEB_PORT:-8080}"
ws_port="${DECONZ_WS_PORT:-8443}"
upnp="${DECONZ_UPNP:-0}"

# UNVERIFIED: option names come from the plan, not from `deCONZ --help`. Confirm inside the built image.
exec /usr/bin/deCONZ \
  --http-listen="0.0.0.0:${web_port}" \
  --ws-port="${ws_port}" \
  --upnp="${upnp}" \
  --dbpath=/config/zll.db \
  --configpath=/config
