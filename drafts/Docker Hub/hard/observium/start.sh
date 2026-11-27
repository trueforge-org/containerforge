#!/usr/bin/env bash
# Observium start for ContainerForge. Writes only to /config (persistent) and /tmp (ephemeral); /app is read-only.
# Database password is passed through the environment (MYSQL_PWD), never on a command line or in a file.

APP_DIR=/app/observium
DB_HOST="${OBSERVIUM_db_host:-mariadb}"
DB_NAME="${OBSERVIUM_db_name:-observium}"
DB_USER="${OBSERVIUM_db_user:-observium}"
DB_PORT=3306
ADMIN_USER="${OBSERVIUM_ADMIN_USER:-admin}"
ADMIN_PASS="${OBSERVIUM_ADMIN_PASS:-admin}"
export MYSQL_PWD="${OBSERVIUM_db_pass:-observiumpwd}"

db_up() {
    nc -z "${DB_HOST}" "${DB_PORT}" 2>/dev/null
}

# create directory structure
mkdir -p \
    /config/rrd \
    /config/logs \
    /tmp/apache/run \
    /tmp/apache/lock \
    /tmp/apache/log \
    /tmp/php-sessions

# seed config.php only when missing or empty (never overwrite user state)
if [[ ! -s /config/config.php ]]; then
    cp /defaults/config.php /config/config.php
fi

# wait up to 60 s for the database; Apache starts regardless so the container stays up
echo "[observium] waiting for database ${DB_HOST}:${DB_PORT}"
for _ in $(seq 1 60); do
    if db_up; then
        break
    fi
    sleep 1
done

if db_up; then
    echo "[observium] database reachable, updating schema"
    cd "${APP_DIR}" || exit 1
    # idempotent schema create/migrate
    php discovery.php -u

    # escape the admin name for SQL (backslash, then single quote)
    sql_user="${ADMIN_USER//\\/\\\\}"
    sql_user="${sql_user//\'/\'\'}"
    count=$(mysql -N -B -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" "${DB_NAME}" \
        -e "SELECT COUNT(*) FROM users WHERE username='${sql_user}'" 2>/dev/null)
    # UNVERIFIED: the users table and column names; check against the schema on first run.
    if [[ "${count}" == "0" ]]; then
        echo "[observium] creating admin user ${ADMIN_USER}"
        # UNVERIFIED: adduser.php takes the password as an argument, so it is briefly visible in the process list.
        php adduser.php "${ADMIN_USER}" "${ADMIN_PASS}" 10
    fi
else
    echo "[observium] database not reachable after 60 s, schema and admin steps skipped"
fi

# background scheduler (no cron daemon). Every 5 min: poller and new-device discovery.
# Every 6 h (72 ticks): full discovery. Daily (288 ticks): housekeeping.
# Deviation: fixed tick counts instead of the clock times used by the upstream cron file.
scheduler() {
    local tick=0
    while true; do
        sleep 300
        tick=$((tick + 1))
        if ! db_up; then
            echo "[observium] scheduler: database unreachable, skipping tick ${tick}"
            continue
        fi
        cd "${APP_DIR}" || continue
        # UNVERIFIED: observium-wrapper is shipped in the tarball; confirm it runs outside /opt/observium.
        ./observium-wrapper poller >>/config/logs/poller-wrapper.log 2>&1
        php discovery.php -h new >>/config/logs/discovery.log 2>&1
        if (( tick % 72 == 0 )); then
            php discovery.php -h all >>/config/logs/discovery.log 2>&1
        fi
        if (( tick % 288 == 0 )); then
            php housekeeping.php -ysel >>/config/logs/housekeeping.log 2>&1
            php housekeeping.php -yrptb >>/config/logs/housekeeping.log 2>&1
        fi
    done
}
scheduler &

exec apache2 -f /etc/observium/apache2.conf -DFOREGROUND
