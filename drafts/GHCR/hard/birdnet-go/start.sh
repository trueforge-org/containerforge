#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. Config and state go to /config, clips to /data, scratch to /tmp.
mkdir -p /config /data/clips

export BIRDNET_WEBSERVER_PORT="${BIRDNET_WEBSERVER_PORT:-8080}"

# UNVERIFIED: upstream entrypoint.sh and startup-wrapper.sh were not read. Seeding of a default
# config into /config and the bind address are not confirmed yet.
cd /config
exec /app/birdnet-go/birdnet-go realtime
