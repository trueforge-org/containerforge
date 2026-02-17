#!/usr/bin/env bash


cd /app || exit 1

mkdir -p /config/logs

if [[ -n ${DATABASE_URL} ]]; then
    DB_HOST=$(awk -F '@|:|/' '{print $6}' <<<"${DATABASE_URL}")
    DB_PORT=$(awk -F '@|:|/' '{print $7}' <<<"${DATABASE_URL}")
    DB_USER=$(awk -F '@|:|/' '{print $4}' <<<"${DATABASE_URL}")
    if [[ ! ${DB_PORT} =~ [0-9]+ ]]; then DB_PORT="5432"; fi
    echo "Waiting for DB ${DB_HOST} to become available on port ${DB_PORT}..."
    END=$((SECONDS + 30))
    while [[ ${SECONDS} -lt ${END} ]] && [[ -n "${DB_HOST+x}" ]]; do
        if pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -q; then
            if [[ ! -f /run/dbwait.lock ]]; then
                sleep 5
            fi
            touch /run/dbwait.lock
            break
        else
            sleep 1
        fi
    done
else
    echo "No database configured, sleeping..."
    sleep infinity
fi

echo "Migrating database..."

    TZ=UTC  node db/init.js





export NODE_ENV=production

# See https://github.com/plankanban/planka/issues/253
export TZ=UTC


HOME=/config

cd /app
exec node app.js --prod
