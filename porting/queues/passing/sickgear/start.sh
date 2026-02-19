#!/usr/bin/env bash


#make our folders and links
mkdir -p \
    /config

# If needed add dafault config
if [[ ! -f /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

exec /app/venv/bin/python/app/sickgear/sickgear.py --datadir /config

