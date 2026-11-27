#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/backup-data

# FILE__<NAME> secret loader, same behaviour as upstream entry.sh
while IFS= read -r line; do
    name="${line%%=*}"
    path="${line#*=}"
    if [ -f "${path}" ]; then
        export "${name#FILE__}=$(cat "${path}")"
    else
        echo "Error: Secret file '${path}' does not exist" >&2
        exit 1
    fi
done < <(env | grep '^FILE__' || true)

# JWT secret: generate once and keep it in /config
if [ -z "${JWT_SECRET:-}" ]; then
    if [ ! -s /config/jwt_secret ]; then
        head -c 32 /dev/urandom | base64 > /config/jwt_secret
    fi
    export JWT_SECRET="$(cat /config/jwt_secret)"
fi

# no password means the database connection will fail; keep starting so the web UI
# reports the problem instead of the container exiting
if [ -z "${POSTGRES_PASSWORD:-}" ]; then
    echo "Warning: POSTGRES_PASSWORD (or FILE__POSTGRES_PASSWORD) is not set" >&2
fi

cd /app/backend
exec node server.js
