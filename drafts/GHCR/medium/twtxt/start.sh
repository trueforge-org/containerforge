#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. /app is read-only at runtime.
mkdir -p /config/feeds
cd /config

# UNVERIFIED: twtd flags, config file path and data dir (upstream used /data and /config/feeds).
# Check `twtd --help` in the built image and remap the data dir to /config.
exec /app/twtd
