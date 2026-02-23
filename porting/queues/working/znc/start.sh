#!/usr/bin/env bash


# make folders
mkdir -p \
    /config/configs

# generate license file
if [[ ! -f /config/znc.pem ]]; then
    /usr/local/bin/znc -d /config -p
fi

while [[ ! -f "/config/znc.pem" ]]; do
    echo "waiting for pem file to be generated"
    sleep 2s
done

# copy config
if [[ ! -f /config/configs/znc.conf ]]; then
    cp /defaults/znc.conf /config/configs/znc.conf
fi

PORT=$(grep "Port =" /config/configs/znc.conf | awk -F '=' '{print $2;exit}')

exec /usr/local/bin/znc -d /config \
        --foreground

