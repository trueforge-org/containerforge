#!/usr/bin/env bash
set -euo pipefail

# Defaults only when unset. Secrets (DELUGE_RPC_PASSWORD, STORM_API_KEY) are
# read from the environment by the binary and are never echoed or passed as flags.
export LISTEN_ADDR="${LISTEN_ADDR:-0.0.0.0:8221}"
export DELUGE_RPC_VERSION="${DELUGE_RPC_VERSION:-v1}"

cd /app
exec /app/storm
