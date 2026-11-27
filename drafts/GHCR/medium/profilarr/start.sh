#!/usr/bin/env bash
set -euo pipefail

# Upstream entrypoint: turn NAME_FILE env vars into NAME (file contents).
while IFS= read -r file_var; do
    [ -z "${file_var}" ] && continue
    var="${file_var%_FILE}"
    path="${!file_var}"
    if [ -r "${path}" ]; then
        export "${var}=$(cat "${path}")"
    else
        echo "Warning: ${file_var} points to unreadable file ${path}" >&2
    fi
done < <(env | cut -d= -f1 | grep -E '^[A-Za-z_][A-Za-z0-9_]*_FILE$' || true)

umask "${UMASK:-022}"

export PORT="${PORT:-6868}"
export HOST="${HOST:-0.0.0.0}"
export APP_BASE_PATH=/config
export TZ="${TZ:-Etc/UTC}"
export DENO_DIR="${DENO_DIR:-/tmp/deno-cache}"
# UNVERIFIED: DENO_SQLITE_PATH is Alpine-specific upstream. Resolve the Ubuntu multiarch path
# of libsqlite3 and confirm the app needs it at all in the build.
if [ -z "${DENO_SQLITE_PATH:-}" ]; then
    DENO_SQLITE_PATH="$(compgen -G '/usr/lib/*/libsqlite3.so.0' | head -n 1 || true)"
    export DENO_SQLITE_PATH
fi

mkdir -p /tmp/deno-cache
# Seed the sqlite plugin cache from /app into the writable DENO_DIR (UNVERIFIED path, see Dockerfile).
if [ -d /app/deno-cache/plug ] && [ ! -d /tmp/deno-cache/plug ]; then
    cp -r /app/deno-cache/plug /tmp/deno-cache/plug
fi
mkdir -p /config/data /config/logs /config/backups /config/databases

exec /app/profilarr
