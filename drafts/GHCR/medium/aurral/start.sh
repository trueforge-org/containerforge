#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Upstream's entrypoint (privilege drop and AURRAL_DATA_DIR) is replaced by this script.
mkdir -p /config

cd /app/aurral
# UNVERIFIED: the app's own data path under /config (upstream default AURRAL_DATA_DIR=/config). Confirm on the first run.
# UNVERIFIED: the server must listen on all interfaces, check on the first run.
exec node --max-semi-space-size=4 backend/server.ts
