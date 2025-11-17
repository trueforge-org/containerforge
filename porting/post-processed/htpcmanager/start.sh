#!/usr/bin/env bash




# permissions

    /app \
    /config





exec \
    
         python3 /app/htpcmanager/Htpc.py \
        --datadir /config





exec \
    vnstatd -n

