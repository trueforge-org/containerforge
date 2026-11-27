#!/usr/bin/env bash
set -euo pipefail

export CONFIG_DIR="${CONFIG_DIR:-/config}"
export LOGS_DIR="${LOGS_DIR:-/config/logs}"

# create state directories only when missing; nothing is seeded or overwritten
mkdir -p "$CONFIG_DIR" "$LOGS_DIR"

cd /app
# UNVERIFIED: Node 24 runs .ts directly (type stripping), as upstream CMD does
exec node /app/src/backend/index.ts
