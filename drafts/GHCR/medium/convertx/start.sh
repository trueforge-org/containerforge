#!/usr/bin/env bash
set -euo pipefail

# /app/data is a build-time symlink to /config/data, so the app's data dir lives in /config.
mkdir -p /config/data

exec /app/convertx "$@"
