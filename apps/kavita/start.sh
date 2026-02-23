#!/usr/bin/env bash

if [[ ! -f "/config/appsettings.json" ]]; then
    if [[ -f /defaults/appsettings-init.json ]]; then
        cp /defaults/appsettings-init.json /config/
    elif [[ -f /app/config/appsettings-init.json ]]; then
        cp /app/config/appsettings-init.json /config/
    fi
fi

cd /app
exec /app/Kavita $@

