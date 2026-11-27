#!/usr/bin/env bash
set -euo pipefail

export IPFS_PATH="${IPFS_PATH:-/config/ipfs}"
mkdir -p "$IPFS_PATH"

# first start only, as upstream: later starts keep the existing config untouched
if [ ! -e "$IPFS_PATH/config" ]; then
  ipfs init ${IPFS_PROFILE:+"--profile=$IPFS_PROFILE"}
  # kubo defaults to 127.0.0.1; other containers must reach the API and gateway
  ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
  if [ -n "${IPFS_SWARM_KEY:-}" ]; then
    printf '%s\n' "$IPFS_SWARM_KEY" > "$IPFS_PATH/swarm.key"
    chmod 0400 "$IPFS_PATH/swarm.key"
  fi
  if [ -n "${IPFS_SWARM_KEY_FILE:-}" ]; then
    install -m 0400 "$IPFS_SWARM_KEY_FILE" "$IPFS_PATH/swarm.key"
  fi
fi
unset IPFS_SWARM_KEY IPFS_SWARM_KEY_FILE

exec ipfs daemon --migrate=true --agent-version-suffix=containerforge
