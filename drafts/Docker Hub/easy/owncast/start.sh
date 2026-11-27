#!/usr/bin/env bash
set -euo pipefail

# Owncast keeps its database, HLS output and backups relative to the working directory.
cd /config
mkdir -p /config/data

# UNVERIFIED: HLS segments are written to data/hls. Consider a symlink to /tmp to keep
# high-write data off the persistent volume, once owncast is confirmed to accept it.

exec /app/owncast
