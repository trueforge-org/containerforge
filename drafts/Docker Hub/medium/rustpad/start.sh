#!/usr/bin/env bash
set -eu

# SQLite snapshot file on the persistent volume by default.
# Unset SQLITE_URI selects the default file. Set but empty means memory only, so an empty
# value is unset rather than passed on (an empty URI would make the database open fail).
if [ -z "${SQLITE_URI:-}" ]; then
    if [ "${SQLITE_URI+set}" = "set" ]; then
        unset SQLITE_URI
    else
        export SQLITE_URI="sqlite:///config/rustpad_db.db"
    fi
fi
export PORT="${PORT:-3030}"
export EXPIRY_DAYS="${EXPIRY_DAYS:-1}"
export RUST_LOG="${RUST_LOG:-info}"

cd /app/rustpad
exec ./rustpad-server
