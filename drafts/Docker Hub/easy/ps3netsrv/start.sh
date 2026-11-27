#!/usr/bin/env bash
set -euo pipefail

port="${PS3NETSRV_PORT:-38008}"
args=(/games "$port")
if [[ -n "${PS3NETSRV_WHITELIST:-}" ]]; then
  args+=("$PS3NETSRV_WHITELIST")
fi

echo "Starting ps3netsrv on port ${port}, serving /games"
exec /app/ps3netsrv "${args[@]}"
