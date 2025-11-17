#!/usr/bin/env bash




# make our folders
mkdir -p \
    /config/fonts

# copy config
if [[ ! -f /config/preferences.json ]]; then
    cp /defaults/preferences.json /config/preferences.json
fi

# permissions

    /config





JAVAMEM=${MAXMEM:-512}
PORT=$(jq -r '.adminPortNumber' < /config/preferences.json)

exec \
    
        cd /app/ubooquity  java -Xmx"$JAVAMEM"m \
        -jar /app/ubooquity/Ubooquity.jar \
        --headless --host 0.0.0.0 --remoteadmin \
        --workdir /config

