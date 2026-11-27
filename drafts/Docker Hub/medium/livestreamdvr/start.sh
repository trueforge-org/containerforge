#!/usr/bin/env bash
set -euo pipefail

# /app/livestreamdvr/data is a symlink to /config/data. The subfolders follow the chart mounts.
# UNVERIFIED: these folder names are not confirmed against the source.
mkdir -p /config/data/config /config/data/cache /config/data/logs /config/data/storage

# UNVERIFIED: yarn must be on PATH in the final image. If it is not, run node on the built entry file instead.
cd /app/livestreamdvr/server
exec yarn run start
