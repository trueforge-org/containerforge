#!/usr/bin/env bash


exec python3 /app/htpcmanager/Htpc.py \
        --datadir /config

## TODO: will never run
exec vnstatd -n

