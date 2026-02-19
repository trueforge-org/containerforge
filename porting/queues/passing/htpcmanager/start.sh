#!/usr/bin/env bash


exec /app/venv/bin/python/app/htpcmanager/Htpc.py \
        --datadir /config

## TODO: will never run
exec vnstatd -n

