#!/usr/bin/env bash

mkdir -p /config
[[ -s /config/bitcoin.conf ]] || cp /defaults/bitcoin.conf /config/bitcoin.conf

args=(-datadir=/config -conf=/config/bitcoin.conf -printtoconsole)
[[ -n "${BITCOIN_PRUNE_MB:-}" ]] && args+=("-prune=${BITCOIN_PRUNE_MB}")

# P2P (8333) listens on all interfaces. RPC stays on localhost unless BITCOIN_RPC_ALLOW_IP is set, so a node
# without RPC credentials is not reachable from other containers by default.
# UNVERIFIED: -rpcbind and -rpcallowip are standard Bitcoin Core options, confirm with `bitcoind -help`.
if [[ -n "${BITCOIN_RPC_ALLOW_IP:-}" ]]; then
  echo "[start.sh] RPC bound to all interfaces, allowed from ${BITCOIN_RPC_ALLOW_IP}" >&2
  args+=("-rpcbind=0.0.0.0" "-rpcallowip=${BITCOIN_RPC_ALLOW_IP}")
else
  echo "[start.sh] RPC kept on localhost (set BITCOIN_RPC_ALLOW_IP to change)" >&2
fi

exec /app/bin/bitcoind "${args[@]}" "$@"
