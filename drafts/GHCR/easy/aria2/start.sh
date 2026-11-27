#!/usr/bin/env bash
set -euo pipefail

umask "${UMASK:-022}"

RPC_PORT="${RPC_PORT:-6800}"
LISTEN_PORT="${LISTEN_PORT:-6888}"

mkdir -p /config /downloads

# Seed config and session only when missing. Never overwrite user state.
if [ ! -f /config/aria2.conf ]; then
    cp /defaults/aria2.conf /config/aria2.conf
fi
if [ ! -f /config/aria2.session ]; then
    touch /config/aria2.session
fi

args=()
# UNVERIFIED: aria2 has no env option for the RPC secret, so it is passed on the command line and is visible in the process list.
if [ -n "${RPC_SECRET:-}" ]; then
    args+=("--rpc-secret=${RPC_SECRET}")
fi

exec aria2c \
    --conf-path=/config/aria2.conf \
    --rpc-listen-port="${RPC_PORT}" \
    --listen-port="${LISTEN_PORT}" \
    --dir=/downloads \
    "${args[@]}"
