#!/usr/bin/env bash

# seed config only when missing
if [[ ! -f /config/appsettings.json ]]; then
    cp /defaults/appsettings.json /config/appsettings.json
fi

cd /app/feedcord
exec /app/dotnet/dotnet /app/feedcord/FeedCord.dll "${CONFIGFILE:-/config/appsettings.json}"
