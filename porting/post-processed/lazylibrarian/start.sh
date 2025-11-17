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
cp /defaults/version.txt /config/cache/version.txt

# permissions

    /config


    /downloads \
    /books





exec \
    
         python3 /app/lazylibrarian/LazyLibrarian.py \
        --datadir /config --nolaunch

