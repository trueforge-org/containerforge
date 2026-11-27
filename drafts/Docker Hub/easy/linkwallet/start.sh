#!/usr/bin/env bash
set -euo pipefail

export GIN_MODE="${GIN_MODE:-release}"
export PORT="${PORT:-8080}"
DB_PATH="${DB_PATH:-/config/linkwallet.db}"

# The app creates the bolt DB and the .bleve index on first start and reuses them afterwards.
mkdir -p "$(dirname "${DB_PATH}")"

cd /config
exec /app/linkwallet -db-path "${DB_PATH}"
