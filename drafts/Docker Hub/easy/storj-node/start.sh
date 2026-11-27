#!/usr/bin/env bash
set -euo pipefail

export STORJ_CONSOLE_ADDRESS="${STORJ_CONSOLE_ADDRESS:-0.0.0.0:14002}"
CONF=/config
ID="${CONF}/identity"

# An identity is mandatory and is created and authorized by hand (see the PR notes).
# Stay alive and idle so an empty /config does not crash-loop; no port is opened.
# UNVERIFIED design choice for maintainers: idle here vs exit non-zero.
if [ ! -s "${ID}/identity.cert" ] || [ ! -s "${ID}/identity.key" ] || [ ! -s "${ID}/ca.cert" ]; then
  echo "storj-node: no identity in ${ID}. Create one first, for example:" >&2
  echo "  docker run --rm -v <config>:/config --entrypoint /app/identity <image> create storagenode --identity-dir /config/identity" >&2
  echo "  then authorize it with your token (docs.storj.io/node) and restart." >&2
  exec sleep infinity
fi

args=(--config-dir "${CONF}" --identity-dir "${ID}")
if [ -n "${STORAGE:-}" ]; then args+=("--storage.allocated-disk-space=${STORAGE}"); fi
if [ -n "${ADDRESS:-}" ]; then args+=("--contact.external-address=${ADDRESS}"); fi
if [ -n "${EMAIL:-}" ]; then args+=("--operator.email=${EMAIL}"); fi
if [ -n "${WALLET:-}" ]; then args+=("--operator.wallet=${WALLET}"); fi
if [ -n "${LOG_LEVEL:-}" ]; then args+=("--log.level=${LOG_LEVEL}"); fi

# First start on a fresh config volume: create config.yaml (what SETUP=true does upstream).
# setup only runs while config.yaml is absent; the identity is never generated or overwritten.
if [ ! -e "${CONF}/config.yaml" ]; then
  /app/storagenode setup "${args[@]}"
fi

exec /app/storagenode run "${args[@]}"
