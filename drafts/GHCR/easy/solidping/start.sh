#!/usr/bin/env bash
set -euo pipefail

# The server creates its SQLite database and the file store on first start. Only the directories are needed.
mkdir -p "${SP_DB_DIR:-/config}" "${SP_FILESTORAGE_LOCAL_ROOT:-/config/files}"

# Upstream: the first admin password is printed once when SP_ADMIN_PASSWORD is unset.
# UNVERIFIED: the exact log line; check it on the first run.
exec /app/solidping/solidping serve
