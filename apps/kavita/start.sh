#!/usr/bin/env bash

if [[ ! -f "/config/appsettings.json" ]]; then
    cp /defaults/appsettings-init.json /config/
fi

echo "config content:"
ls -l config

cd /app
exec /app/Kavita $@

