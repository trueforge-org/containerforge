#!/usr/bin/env bash
set -euo pipefail

export HOME=/tmp
export npm_config_cache=/tmp/npm
export NODE_ENV=production
export PRISMA_HIDE_UPDATE_MESSAGE=1

API_DIR=/app/ghostfolio/apps/api
SECRET_DIR=/config/secrets

if [ -z "${DATABASE_URL:-}" ]; then
    echo "Error: DATABASE_URL is required, for example postgresql://user:password@host:5432/db" >&2
    exit 1
fi

if [ -z "${REDIS_HOST:-}" ]; then
    echo "Error: REDIS_HOST is required." >&2
    exit 1
fi

# Use the value from the environment when set. Otherwise keep a generated value in /config/secrets.
load_secret() {
    local name="$1"
    local file="${SECRET_DIR}/${name}"
    if [ -n "${!name:-}" ]; then
        return 0
    fi
    mkdir -p "${SECRET_DIR}"
    chmod 700 "${SECRET_DIR}"
    if [ ! -s "${file}" ]; then
        (umask 077 && openssl rand -hex 32 > "${file}")
    fi
    export "${name}=$(cat "${file}")"
}

load_secret ACCESS_TOKEN_SALT
load_secret JWT_SECRET_KEY

wait_for_tcp() {
    local host="$1" port="$2" name="$3" attempt=0
    until (exec 3<>"/dev/tcp/${host}/${port}") >/dev/null 2>&1; do
        attempt=$((attempt + 1))
        if [ "${attempt}" -gt 60 ]; then
            echo "Error: ${name} at ${host}:${port} is not reachable." >&2
            exit 1
        fi
        echo "waiting for ${name} at ${host}:${port}"
        sleep 2
    done
}

# Parse host and port from DATABASE_URL (scheme://[user[:pass]@]host[:port]/db).
db_url_rest="${DATABASE_URL#*://}"
db_hostport="${db_url_rest##*@}"
db_hostport="${db_hostport%%[/?]*}"
db_host="${db_hostport%%:*}"
db_port="${db_hostport#*:}"
if [ "${db_port}" = "${db_hostport}" ]; then
    db_port=5432
fi

wait_for_tcp "${db_host}" "${db_port}" "database"
wait_for_tcp "${REDIS_HOST}" "${REDIS_PORT:-6379}" "redis"

cd "${API_DIR}"

# Both commands are idempotent, as in the upstream entrypoint.
npx prisma migrate deploy
npx prisma db seed

exec node main
