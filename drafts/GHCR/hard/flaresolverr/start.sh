#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives under /config. Only create the directory; nothing is overwritten.
mkdir -p /config

# Upstream copies src/ to /app and runs `python -u /app/flaresolverr.py`. Here the same file is
# src/flaresolverr.py under the extracted source tree, so package.json and other relative paths still resolve.
# UNVERIFIED: this entry point against the v3.5.2 tag (the upstream CMD was read from the pinned commit).
cd /app/flaresolverr
exec /app/flaresolverr/venv/bin/python -u src/flaresolverr.py
