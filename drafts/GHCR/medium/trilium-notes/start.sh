#!/usr/bin/env bash

set -eu

# bind all interfaces so other containers can reach the server (defaults also set in the Dockerfile)
export TRILIUM_NETWORK_HOST="${TRILIUM_NETWORK_HOST:-0.0.0.0}"
export TRILIUM_NETWORK_PORT="${TRILIUM_NETWORK_PORT:-8080}"

# HOME=/config (set in the Dockerfile) keeps the data dir on the persistent volume.
# UNVERIFIED: the data dir name and any TRILIUM_DATA_DIR-style override must be confirmed in the v0.107.0 source
# (data_dir.ts was not fetched). Trilium creates its own data files on first start; nothing is seeded here.
# Never write to /app; scratch goes to /tmp (TMPDIR).

# UNVERIFIED: node may not be present in the image or bundled in the tarball; confirm `ls /app` and `which node`
# in the first build. Entry script name is also UNVERIFIED.
exec node /app/trilium.mjs
