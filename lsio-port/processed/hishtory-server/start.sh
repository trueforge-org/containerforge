# ===== From ./processed/hishtory-server/root/etc/s6-overlay//s6-rc.d/init-hishtory-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n ${HISHTORY_POSTGRES_DB} ]]; then
    DB_HOST=$(awk -F '@|:|/' '{print $6}' <<<"${HISHTORY_POSTGRES_DB}")
    DB_PORT=$(awk -F '@|:|/' '{print $7}' <<<"${HISHTORY_POSTGRES_DB}")
    DB_USER=$(awk -F '@|:|/' '{print $4}' <<<"${HISHTORY_POSTGRES_DB}")
    echo "Waiting for DB ${DB_HOST} to become available on port ${DB_PORT}..."
    while :; do
        if pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -q; then
            exit 0
        fi
        sleep 3
    done
elif [[ -n ${HISHTORY_SQLITE_DB} ]]; then
    echo "Using SQLite database, ensure you have mounted $(dirname "${HISHTORY_SQLITE_DB}") to your host"
else
    echo "No database configured, sleeping..."
    sleep infinity
fi

# ===== From ./processed/hishtory-server/root/etc/s6-overlay//s6-rc.d/svc-hishtory/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 \
            s6-setuidgid abc /app/server
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 \
            /app/server
fi

