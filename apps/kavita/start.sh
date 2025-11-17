#!/usr/bin/env bash

if [[ ! -f "/config/appsettings.json" ]]; then
    cp /defaults/appsettings-init.json /config/
fi

cd /app
exec /app/Kavita $@

