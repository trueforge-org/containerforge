#!/usr/bin/env bash

# Environment variables
: "${DB_TYPE:=sqlite}"

if [[ "$DBTYPE" == "postgres" ]]; then

echo "Postgres selected as database type, starting configuration..."

CONFIG_FILE="./config.xml" # Adjust path if needed
if [[ ! -f "$CONFIG_FILE" ]]; then
# Start Lidarr in the background
/app/bin/Lidarr --nobrowser --data=/config "$@" &

# Capture its PID
LIDARR_PID=$!

echo "Waiting 30 seconds before exiting..."
sleep 30

# Optionally, stop Lidarr if desired
echo "Stopping Lidarr..."
kill "$LIDARR_PID"
fi

: "${DB_USER:?Need to set DB_USER}"
: "${DB_PASSWORD:?Need to set DB_PASSWORD}"
: "${DB_DATABASE:?Need to set DB_DATABASE}"
: "${DB_LOGSDATABASE:?Need to set DB_LOGSDATABASE}"
: "${DB_HOST:?Need to set DB_HOST}"
: "${DB_PORT:?Need to set DB_PORT}"

echo "Updating Lidarr config.xml for PostgreSQL..."

xmlstarlet ed -L \
    -u "/Config/PostgresUser" -v "$DB_USER" \
    -u "/Config/PostgresPassword" -v "$DB_PASSWORD" \
    -u "/Config/PostgresHost" -v "$DB_HOST" \
    -u "/Config/PostgresPort" -v "$DB_PORT" \
    -u "/Config/PostgresMainDb" -v "$DB_DATABASE" \
    -u "/Config/PostgresLogDb" -v "$DB_LOGSDATABASE" \
    "$CONFIG_FILE"

echo "Databases created and config.xml updated."
fi

 exec \
     /app/bin/Lidarr \
         --nobrowser \
         --data=/config \
         "$@"
