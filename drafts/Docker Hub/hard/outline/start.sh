#!/usr/bin/env bash

set -euo pipefail

mkdir -p "${FILE_STORAGE_LOCAL_ROOT_DIR:-/config/data}" /tmp/outline

export PORT="${PORT:-3000}"
export FORCE_HTTPS="${FORCE_HTTPS:-false}"
export URL="${URL:-http://localhost:${PORT}}"

# Outline cannot start without these. Serve a placeholder on all interfaces instead of exiting,
# so the container stays up with an empty /config and a missing-variables message in the log.
missing=""
for var in SECRET_KEY UTILS_SECRET DATABASE_URL REDIS_URL; do
    [[ -n "${!var:-}" ]] || missing="${missing} ${var}"
done

if [[ -n "${missing}" ]]; then
    echo "Outline needs${missing}; starting placeholder server on 0.0.0.0:${PORT}"
    exec node -e "require('http').createServer((q,r)=>{r.writeHead(200,{'Content-Type':'text/plain'});r.end('OK: Outline is missing required environment variables');}).listen(${PORT},'0.0.0.0')"
fi

# Outline runs its database migrations itself on every start.
cd /app/outline
exec node build/server/index.js
