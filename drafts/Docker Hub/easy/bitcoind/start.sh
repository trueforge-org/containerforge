#!/usr/bin/env bash
set -euo pipefail

ARGS=(-datadir=/config -conf=/config/bitcoin.conf -printtoconsole)

# Create an empty bitcoin.conf only when missing, so a custom -conf never errors. Never overwrites.
[ -f /config/bitcoin.conf ] || : > /config/bitcoin.conf

# Bitcoin Core ignores -rpcbind unless -rpcallowip is also set. Default: RPC stays on localhost.
# This deviates from the "listen on all interfaces" rule on purpose (secure default, see PR notes).
if [ -n "${BITCOIN_RPCALLOWIP:-}" ]; then
  ARGS+=(-rpcbind=0.0.0.0)
  IFS=',' read -r -a ips <<< "${BITCOIN_RPCALLOWIP}"
  for ip in "${ips[@]}"; do
    ARGS+=("-rpcallowip=${ip// /}")
  done
else
  echo "BITCOIN_RPCALLOWIP is empty: JSON-RPC (8332) listens on localhost only."
fi

[ -n "${BITCOIN_RPCAUTH:-}" ] && ARGS+=("-rpcauth=${BITCOIN_RPCAUTH}")

# exec: bitcoind becomes the tini child so SIGTERM gives a clean shutdown.
exec /app/bin/bitcoind "${ARGS[@]}" "$@"
