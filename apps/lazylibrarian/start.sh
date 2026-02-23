#!/usr/bin/env bash

# make folders
mkdir -p \
    /config/log \
    /config/cache \
    /downloads \
    /books

# copy config
if [[ ! -e /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

# update version.txt
if [[ -f /defaults/version.txt ]]; then
    cp /defaults/version.txt /config/cache/version.txt
elif [[ ! -f /config/cache/version.txt ]]; then
    echo "unknown" > /config/cache/version.txt
fi

exec python3 /app/lazylibrarian/LazyLibrarian.py \
        --datadir /config --nolaunch

