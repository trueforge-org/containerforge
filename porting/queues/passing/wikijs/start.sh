#!/usr/bin/env bash


if [[ -z ${DB_TYPE} ]]; then
    printf "sqlite" > /run/s6/container_environment/DB_TYPE
fi

if [[ ! -f "/config/config.yml" ]]; then
    cp /defaults/config.yml /config/config.yml
fi

export CONFIG_FILE="/config/config.yml"

cd /app/wiki
exec /usr/bin/node server
