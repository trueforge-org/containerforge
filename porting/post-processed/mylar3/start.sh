#!/usr/bin/env bash


# make folders
mkdir -p /config/{mylar,scripts}

# copy scripts folder to config
if [[ ! -f /config/scripts/autoProcessComics.py ]]; then
    cp -pr /app/mylar3/post-processing/* /config/scripts/
fi

exec python3 /app/mylar3/Mylar.py --nolaunch \
        --datadir /config/mylar

