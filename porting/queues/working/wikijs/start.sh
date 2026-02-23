#!/usr/bin/env bash


export DB_TYPE="${DB_TYPE:-sqlite}"

if [[ ! -f "/config/config.yml" ]]; then
    cp /defaults/config.yml /config/config.yml
fi

export CONFIG_FILE="/config/config.yml"

cd /app/wiki
exec /usr/bin/node server
