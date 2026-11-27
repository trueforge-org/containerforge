#!/bin/sh
# Initial draft: starts proxmox-backup-api and proxmox-backup-proxy. UNVERIFIED end to end (plan sections 9 and 10).
# Runs as the apps user. Nothing is written to the image; state lives in /config, runtime files in /tmp.
set -eu

CONFIG_ROOT=/config
SEED=/usr/share/proxmox-backup-defaults

mkdir -p "$CONFIG_ROOT/etc" "$CONFIG_ROOT/lib" "$CONFIG_ROOT/log" /tmp/run
chmod 700 /tmp/run

# Seed only when empty, so existing user state is never overwritten.
if [ ! -e "$CONFIG_ROOT/etc/.seeded" ] && [ -z "$(ls -A "$CONFIG_ROOT/etc" 2>/dev/null)" ]; then
    cp -a "$SEED/etc/." "$CONFIG_ROOT/etc/"
    touch "$CONFIG_ROOT/etc/.seeded"
fi
if [ -z "$(ls -A "$CONFIG_ROOT/lib" 2>/dev/null)" ]; then
    cp -a "$SEED/lib/." "$CONFIG_ROOT/lib/"
fi

# UNVERIFIED: whether the packages generate the self-signed TLS certificate on first start.
# Default admin login per upstream README is admin@pbs / pbspbs; change it after first login.

proxmox-backup-api &
API_PID=$!

proxmox-backup-proxy &
PROXY_PID=$!

trap 'kill "$PROXY_PID" "$API_PID" 2>/dev/null || true; wait' TERM INT

# Exit as soon as either daemon stops, so the container does not stay half-running.
wait "$PROXY_PID" || true
kill "$API_PID" 2>/dev/null || true
wait "$API_PID" 2>/dev/null || true
