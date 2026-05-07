#!/usr/bin/env bash

# Create required runtime directories in /tmp
mkdir -p /tmp/manyfold/tmp /tmp/manyfold/log

# set secret key if unset
SECRET_FILE="/config/secret_key_base.txt"
if [[ -w /config ]]; then
    # /config is writable, use it
    if [ -n "${SECRET_KEY_BASE}" ]; then
      echo "**** SECRET_KEY_BASE set in environment. ****"
    elif [ -f "${SECRET_FILE}" ] && [ -s "${SECRET_FILE}" ]; then
      export SECRET_KEY_BASE=$(cat "${SECRET_FILE}" | tr -d '[:space:]')
    else
      echo "**** SECRET_KEY_BASE not set, generating. ****"
      KEY=$(ruby -r "securerandom" -e "puts SecureRandom.hex(64)")
      echo "${KEY}" > "${SECRET_FILE}"
      export SECRET_KEY_BASE="${KEY}"
    fi
    printf "%s" "${SECRET_KEY_BASE}" > /var/run/s6/container_environment/SECRET_KEY_BASE

else
    # /config is readonly, use /tmp
    echo "Warning: /config is read-only, using /tmp for runtime data"
    SECRET_FILE="/tmp/manyfold/secret_key_base.txt"
    mkdir -p /tmp/manyfold

    if [ -n "${SECRET_KEY_BASE}" ]; then
      echo "**** SECRET_KEY_BASE set in environment. ****"
    elif [ -f "${SECRET_FILE}" ] && [ -s "${SECRET_FILE}" ]; then
      export SECRET_KEY_BASE=$(cat "${SECRET_FILE}" | tr -d '[:space:]')
    else
      echo "**** SECRET_KEY_BASE not set, generating. ****"
      KEY=$(ruby -r "securerandom" -e "puts SecureRandom.hex(64)")
      echo "${KEY}" > "${SECRET_FILE}"
      export SECRET_KEY_BASE="${KEY}"
    fi
    printf "%s" "${SECRET_KEY_BASE}" > /var/run/s6/container_environment/SECRET_KEY_BASE 2>/dev/null || true
fi

printf %s "$(cat /app/www/GIT_SHA)" > /run/s6/container_environment/GIT_SHA 2>/dev/null || true

# Remove old pid in the event of an unclean shutdown
if [[ -f /app/www/tmp/pids/server.pid ]]; then
    rm /app/www/tmp/pids/server.pid
fi

DB_SCHEME=$(awk -F":" '{print $1}' <<<"${DATABASE_URL}")

if [[ ${DB_SCHEME} = "sqlite3" ]]; then
    DB_PATH=$(awk -F":" '{print $2}' <<<"${DATABASE_URL}")
    mkdir -p "$(dirname "${DB_PATH}")" 2>/dev/null || true
    touch "${DB_PATH}" 2>/dev/null || true
elif [[ ${DB_SCHEME} = "postgresql" ]]; then
    DB_HOST=$(awk -F '@|:|/' '{print $6}' <<<"${DATABASE_URL}")
    DB_PORT=$(awk -F '@|:|/' '{print $7}' <<<"${DATABASE_URL}")
    DB_USER=$(awk -F '@|:|/' '{print $4}' <<<"${DATABASE_URL}")
    if [[ ! ${DB_PORT} =~ [0-9]+ ]]; then DB_PORT=5432; fi
    echo "Waiting for DB to be available"
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
    if [[ -w /config ]]; then
        export DATABASE_URL=sqlite3:/config/manyfold.sqlite3
        printf "sqlite3:/config/manyfold.sqlite3" > /run/s6/container_environment/DATABASE_URL 2>/dev/null || true
    else
        export DATABASE_URL=sqlite3:/tmp/manyfold/manyfold.sqlite3
        printf "sqlite3:/tmp/manyfold/manyfold.sqlite3" > /run/s6/container_environment/DATABASE_URL 2>/dev/null || true
    fi
    echo "**** Missing or invalid DATABASE_URL, defaulting to sqlite. ****"
fi

cd /app/www/ || exit 1

echo "**** Running Manyfold database init. ****"
/usr/bin/bundle exec rails db:prepare:with_data

cd /app/www
exec foreman start
