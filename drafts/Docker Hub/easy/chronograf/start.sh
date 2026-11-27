#!/usr/bin/env bash
set -euo pipefail

export BOLT_PATH="${BOLT_PATH:-/config/chronograf-v1.db}"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-8888}"
export REPORTING_DISABLED="${REPORTING_DISABLED:-true}"

# /config is empty on first start. Chronograf creates the BoltDB file itself.
mkdir -p "$(dirname "${BOLT_PATH}")"

exec /app/chronograf
