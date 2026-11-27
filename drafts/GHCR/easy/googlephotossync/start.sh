#!/usr/bin/env bash
set -euo pipefail

# Token and downloads live under /config. Caches go to /tmp, never /config or /app.
export HOME=/config
export XDG_CACHE_HOME=/tmp/cache

mkdir -p /config/googlephotos /tmp/cache
cd /config/googlephotos

# UNVERIFIED: the config/token and download directory flags and env vars are not in upstream README.rst.
# Run with the tool's defaults until they are confirmed. Do not add flags by guessing.
# A first run without a token needs an interactive browser sign-in, which the tool prompts for.
# Upgrades from before 3.2.4 need `--flush-index` once (upstream README).
exec gphotos-sync "$@"
