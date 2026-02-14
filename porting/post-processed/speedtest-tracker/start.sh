#!/usr/bin/env bash


if [[ "${DB_CONNECTION:=sqlite}" = "sqlite" ]]; then
    if [[ -n "${DB_DATABASE}" ]]; then
        if [[ ! -e "${DB_DATABASE}" ]]; then
            touch "${DB_DATABASE}"

        fi
    else
        touch /config/database.sqlite
        if [[ -e "/app/www/database/database.sqlite" && ! -L "/app/www/database/database.sqlite" ]]; then
            rm -rf "/app/www/database/database.sqlite"
        fi
        if [[ ! -L "/app/www/database/database.sqlite" ]]; then
            ln -s "/config/database.sqlite" "/app/www/database/database.sqlite"
        fi

    fi
    export DB_CONNECTION=sqlite
    echo "sqlite" > /run/s6/container_environment/DB_CONNECTION
elif [[ "${DB_CONNECTION}" = "pgsql" ]]; then
    echo "Waiting for DB to be available"
    END=$((SECONDS + 30))
    while [[ ${SECONDS} -lt ${END} ]] && [[ -n "${DB_HOST+x}" ]]; do
        if pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -q; then
            if [[ ! -f /dbwait.lock ]]; then
                sleep 5
            fi
            touch /dbwait.lock
            break
        else
            sleep 1
        fi
    done
fi

# Check for env file
if [[ -f /config/.env ]]; then
    if [[ -e "/app/www/.env" && ! -L "/app/www/.env" ]]; then
        rm -rf "/app/www/.env"
    fi
    if [[ ! -L "/app/www/.env" ]]; then
        ln -s "/config/.env" "/app/www/.env"
    fi
fi

touch /config/log/laravel.log

if [[ -e "/app/www/storage/logs/laravel.log" && ! -L "/app/www/storage/logs/laravel.log" ]]; then
    rm -rf "/app/www/storage/logs/laravel.log"
fi
if [[ ! -L "/app/www/storage/logs/laravel.log" ]]; then
    ln -s "/config/log/laravel.log" "/app/www/storage/logs/laravel.log"
fi

# Check for app key
if [[ -z ${APP_KEY} ]]; then
    if ! grep -qE "APP_KEY=[0-9A-Za-z:+\/=]{1,}" /app/www/.env 2> /dev/null; then
        echo "An application key is missing, halting init!"
        echo "You can generate a key at https://speedtest-tracker.dev/."
        sleep infinity
    fi
fi

# Build cache
 php /app/www/artisan optimize --no-ansi -q
 php /app/www/artisan filament:cache-components --no-ansi -q

# Migrate database
 php /app/www/artisan migrate --force --no-ansi -q

cd /app/www || exit 1

exec php artisan queue:work --tries=3 --no-ansi -q

