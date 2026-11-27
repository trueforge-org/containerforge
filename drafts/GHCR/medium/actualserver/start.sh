#!/usr/bin/env bash
set -euo pipefail

# ACTUAL_DATA_DIR (default /config/data) is read by the server. Create it only when missing; nothing is seeded.
export ACTUAL_DATA_DIR="${ACTUAL_DATA_DIR:-/config/data}"
mkdir -p "${ACTUAL_DATA_DIR}"

# The server is installed under /app, which is read-only at runtime. It is started from its package directory.
cd /app/actual-server/node_modules/@actual-app/sync-server || exit 1
# UNVERIFIED: the entry file under build/bin. Check it against the packaged layout on the first build.
exec node build/bin/actual-server.js
