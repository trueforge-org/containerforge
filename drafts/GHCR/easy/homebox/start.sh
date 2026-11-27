#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

export HBOX_MODE="${HBOX_MODE:-production}"
export HBOX_WEB_PORT="${HBOX_WEB_PORT:-7745}"
export HBOX_WEB_HOST="${HBOX_WEB_HOST:-0.0.0.0}"
export HBOX_DATABASE_DRIVER="${HBOX_DATABASE_DRIVER:-sqlite3}"
export HBOX_DATABASE_SQLITE_PATH="${HBOX_DATABASE_SQLITE_PATH:-/config/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1&_time_format=sqlite}"
# UNVERIFIED: upstream uses file:///?no_tmp_dir=true (root). Confirm that uploads land under /config.
export HBOX_STORAGE_CONN_STRING="${HBOX_STORAGE_CONN_STRING:-file:///config?no_tmp_dir=true}"
export HBOX_STORAGE_PREFIX_PATH="${HBOX_STORAGE_PREFIX_PATH:-data}"

# UNVERIFIED: upstream CMD passes /data/config.yml. The binary is assumed to start without a config file.
exec /app/homebox
