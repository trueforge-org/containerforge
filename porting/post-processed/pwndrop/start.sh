#!/usr/bin/env bash


mkdir -p /config/data

if [[ ! -f "/config/data/pwndrop.db" ]]; then
    SECRET_PATH=${SECRET_PATH:-/pwndrop}
    echo "New install detected, starting pwndrop with secret path ${SECRET_PATH}"
    echo -e "\n[setup]\nsecret_path = \"${SECRET_PATH}\"" >> /defaults/pwndrop.ini
fi

exec /app/pwndrop/pwndrop \
                -debug \
                -no-autocert \
                -no-dns \
                -config /defaults/pwndrop.ini

