#!/usr/bin/env bash

# Environment variables
: "${DB_TYPE:=sqlite}"

if [[ "$DB_TYPE" == "postgres" ]]; then
    echo "Postgres selected as database type, starting configuration..."

    CONFIG_FILE="./config.xml" # Adjust path if needed
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Missing config file, running Whisparr to ensure configfile can be accessed"

        /app/bin/Whisparr --nobrowser --data=/config "$@" &
        WHISPARR_PID=$!

        timeout=60
        count=0
        while [[ ! -f "$CONFIG_FILE" ]]; do
            sleep 5
            ((count+=5))
            if [[ $count -ge $timeout ]]; then
                echo "Timeout waiting for config.xml"
                kill "$WHISPARR_PID"
                exit 1
            fi
        done

        echo "Config file present, stopping Whisparr..."
        kill "$WHISPARR_PID"
    fi

    : "${DB_USER:?Need to set DB_USER}"
    : "${DB_PASSWORD:?Need to set DB_PASSWORD}"
    : "${DB_DATABASE:=whisparr-main}"
    : "${DB_LOGSDB:=whisparr-log}"
    : "${DB_HOST:=postgres}"
    : "${DB_PORT:=5432}"

    echo "Updating Whisparr config.xml for PostgreSQL..."
    cp -rf "$CONFIG_FILE" "${CONFIG_FILE}.bak"

    xmlstarlet ed -L \
        -u "/Config/PostgresUser" -v "$DB_USER" \
        -u "/Config/PostgresPassword" -v "$DB_PASSWORD" \
        -u "/Config/PostgresHost" -v "$DB_HOST" \
        -u "/Config/PostgresPort" -v "$DB_PORT" \
        -u "/Config/PostgresMainDb" -v "$DB_DATABASE" \
        -u "/Config/PostgresLogDb" -v "$DB_LOGSDB" \
        "$CONFIG_FILE"

    echo "Config.xml updated for PostgreSQL support"
fi

exec \
    /app/bin/Whisparr \
        --nobrowser \
        --data=/config \
        "$@"
