#!/usr/bin/env bash

if [[ ! -f "/config/appsettings.json" ]]; then
    if [[ -f /defaults/appsettings-init.json ]]; then
        cp /defaults/appsettings-init.json /config/
    elif [[ -f /app/config/appsettings-init.json ]]; then
        cp /app/config/appsettings-init.json /config/
    fi
fi

# Kavita rewrites index.html at runtime (base url); /app is read-only
cp -f /defaults/index.html /tmp/index.html

cd /app
exec /app/Kavita "$@"

