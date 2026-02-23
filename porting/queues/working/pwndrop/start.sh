#!/usr/bin/env bash


mkdir -p /config/data
CONFIG_FILE=/config/pwndrop.ini

if [[ ! -f "$CONFIG_FILE" ]]; then
    cp /defaults/pwndrop.ini "$CONFIG_FILE"
fi

if [[ ! -f "/config/data/pwndrop.db" ]]; then
    SECRET_PATH=${SECRET_PATH:-/pwndrop}
    echo "New install detected, starting pwndrop with secret path ${SECRET_PATH}"
    echo -e "\n[setup]\nsecret_path = \"${SECRET_PATH}\"" >> "$CONFIG_FILE"
fi

exec /app/pwndrop/pwndrop \
                -debug \
                -no-autocert \
                -no-dns \
                -config "$CONFIG_FILE"
