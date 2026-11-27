#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config/data, reached through the /app/comet/data symlink.
mkdir -p /config/data

cd /app/comet
exec python -m comet.main
