#!/usr/bin/env bash


# copy config.json if doesn't exist
if [[ ! -f /config/config.json ]]; then
    cp /defaults/config.json /config/config.json
fi

mkdir -p /config/uploads
rm -rf /app/hedgedoc/public/uploads
ln -s /config/uploads /app/hedgedoc/public/uploads

# check for the mysql endpoint
if [[ -n "${DB_HOST+x}" ]]; then
    echo "Waiting for DB to be available"
    END=$((SECONDS+30))
    while [[ ${SECONDS} -lt ${END} ]] && [[ -n "${DB_HOST+x}" ]]; do
        if [[ $(/usr/bin/nc -w1 "${DB_HOST}" "${DB_PORT:-3306}" | tr -d '\0') ]]; then
            if [[ -n "${RUN}" ]]; then
                break
            fi
            RUN="RAN"
            # we sleep here again due to first run init on DB containers
            if [[ ! -f /dbwait.lock ]]; then
                sleep 5
            fi
        else
            sleep 1
        fi
    done
fi

# migration from codimd
if [[ -f "/config/codimd.sqlite" ]] && [[ ! -f "/config/hedgedoc.sqlite" ]]; then
    echo "Migrating codimd sqlite db to hedgedoc"
    mv /config/codimd.sqlite /config/hedgedoc.sqlite
fi


# set lockfile to avoid DB waits for this specific container
touch /dbwait.lock


# if user is using our env variables set the DB_URL
if [[ -n ${DB_HOST+x} ]]; then
    export CMD_DB_URL="${CMD_DB_DIALECT:-mariadb}://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
fi

# set env var for sqlite if db url and db_host unset
if [[ -z ${CMD_DB_URL+x} ]] && [[ -z ${CMD_DB_HOST+x} ]]; then
    export CMD_DB_URL="sqlite:///config/hedgedoc.sqlite"
fi

# set config path
if [[ -z ${CMD_CONFIG_FILE+x} ]]; then
    export CMD_CONFIG_FILE="/config/config.json"
fi

cd /app/hedgedoc
# run program
exec node app.js

