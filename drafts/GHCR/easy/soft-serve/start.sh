#!/usr/bin/env bash
set -euo pipefail

export SOFT_SERVE_DATA_PATH="${SOFT_SERVE_DATA_PATH:-/config/soft-serve}"
# Upstream defaults the stats listener to localhost; bind all interfaces so it is reachable.
export SOFT_SERVE_STATS_LISTEN_ADDR="${SOFT_SERVE_STATS_LISTEN_ADDR:-:23233}"

mkdir -p "${SOFT_SERVE_DATA_PATH}"
cd "${SOFT_SERVE_DATA_PATH}"

exec /app/soft-serve/soft serve
