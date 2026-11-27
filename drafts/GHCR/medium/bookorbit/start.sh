#!/bin/sh
set -eu

# Persistent state lives under /config. The upstream root branch (chown, su-exec, PUID/PGID) is not used.
mkdir -p /config/data/covers /config/data/book-bucket /config/books

if [ ! -w /config/data ]; then
    echo "bookorbit: /config/data is not writable by UID $(id -u). Make /config writable for UID 568." >&2
    exit 1
fi

# Secrets are required and never generated or written to disk by this script.
: "${JWT_SECRET:?JWT_SECRET is required}"
: "${SETUP_BOOTSTRAP_TOKEN:?SETUP_BOOTSTRAP_TOKEN is required}"

# Build DATABASE_URL from POSTGRES_* when it is not set, as the upstream entrypoint does.
# Values are URL-encoded via node and passed in the environment, not in the process arguments.
if [ -z "${DATABASE_URL:-}" ]; then
    : "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required when DATABASE_URL is not set}"
    db_user=$(POSTGRES_USER="${POSTGRES_USER:-bookorbit}" node -p 'encodeURIComponent(process.env.POSTGRES_USER)')
    db_pass=$(POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" node -p 'encodeURIComponent(process.env.POSTGRES_PASSWORD)')
    DATABASE_URL="postgres://${db_user}:${db_pass}@${POSTGRES_HOST:-postgresql}:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-bookorbit}"
    export DATABASE_URL
fi

export NODE_MAX_OLD_SPACE_SIZE="${NODE_MAX_OLD_SPACE_SIZE:-2048}"

cd /app
node dist/scripts/migrate.js
exec node --max-old-space-size="${NODE_MAX_OLD_SPACE_SIZE}" dist/main.js
