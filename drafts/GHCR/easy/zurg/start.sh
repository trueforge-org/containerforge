#!/usr/bin/env bash
set -euo pipefail

# All state lives in /config (WORKDIR), so the default ./config.yml and ./data paths land on the volume.
mkdir -p /config
cd /config

# UNVERIFIED: with no config.yml, zurg may create one from TOKEN on first run (README). If it exits instead,
# seed a minimal /config/config.yml here (only when missing), not the upstream file.
# UNVERIFIED: zurg may download ffprobe and rclone into /config on first run (README "Binary").
# TOKEN is read from the environment by zurg; it is never passed on the command line.
exec /app/zurg/zurg --config /config/config.yml
