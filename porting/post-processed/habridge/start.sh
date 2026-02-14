#!/usr/bin/env bash


# make folders
mkdir -p \
    /config/scripts \

# copy config file
if [[ ! -e /config/ha-bridge.config ]]; then
    cp /defaults/ha-bridge.config /config/ha-bridge.config
fi

exec java \
            -jar \
            -Dconfig.file=/config/ha-bridge.config \
            -Dexec.garden=/config/scripts \
            -Dsecurity.key="$SEC_KEY" \
            /app/ha-bridge.jar

