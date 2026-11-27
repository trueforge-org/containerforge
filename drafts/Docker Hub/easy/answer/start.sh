#!/usr/bin/env bash
set -euo pipefail

export SITE_ADDR="${SITE_ADDR:-0.0.0.0:8080}"
export INSTALL_PORT="${INSTALL_PORT:-8080}"
mkdir -p /config/sqlite3

# Auto-install with SQLite keeps the database under /config.
if [[ -n "${AUTO_INSTALL:-}" && "${DB_TYPE:-sqlite3}" == "sqlite3" ]]; then
  export DB_TYPE="${DB_TYPE:-sqlite3}"
  export DB_FILE="${DB_FILE:-/config/sqlite3/answer.db}"
fi

cd /config
# init serves the install wizard on INSTALL_PORT when no config exists, and returns at once otherwise.
/app/answer init -C /config
/app/answer upgrade -C /config
exec /app/answer run -C /config
