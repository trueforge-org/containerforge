#!/usr/bin/env bash
set -euo pipefail

DB="${SQLITE_DATABASE:-/config/database.db}"
mkdir -p "$(dirname "${DB}")"

# sqlite-web needs the file to exist (read-only mode exits otherwise).
# An empty file is a valid SQLite database. An existing database is never touched.
if [ ! -e "${DB}" ]; then
  python - "${DB}" <<'PY'
import sqlite3, sys
sqlite3.connect(sys.argv[1]).close()
PY
fi

# The app reads SQLITE_WEB_PASSWORD only together with -P. Pass only the switch, so the secret stays out of the process list.
AUTH=()
if [ -n "${SQLITE_WEB_PASSWORD:-}" ]; then
  AUTH=(-P)
fi

# SQLITE_WEB_ARGS is split on purpose (for example -r, -u /prefix/ or -F).
# Never add -P without a password: the app would then prompt on stdin.
# shellcheck disable=SC2086
exec sqlite_wsgi -H 0.0.0.0 -p "${SQLITE_WEB_PORT:-8080}" "${AUTH[@]}" ${SQLITE_WEB_ARGS:-} "${DB}"
