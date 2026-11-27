#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export TZ="${TZ:-Etc/UTC}"

DATA_DIR=/config/bitmonero
mkdir -p "${DATA_DIR}"

cd /app/monero
# Restricted RPC and P2P bind to all interfaces so other containers can reach them.
exec /app/monero/monerod \
  --non-interactive \
  --data-dir="${DATA_DIR}" \
  --rpc-restricted-bind-ip=0.0.0.0 \
  --rpc-restricted-bind-port=18089 \
  --p2p-bind-ip=0.0.0.0 \
  --p2p-bind-port=18080 \
  --no-igd \
  --no-zmq \
  --enable-dns-blocklist
