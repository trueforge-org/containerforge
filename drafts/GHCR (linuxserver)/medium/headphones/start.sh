#!/usr/bin/env bash

# seed config only when missing, never overwrite user state
if [[ ! -f /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

# the app resolves lib/ and data/ relative to its own file, so run from there (read only)
cd /app/headphones || exit 1
exec \
    /usr/local/bin/python \
        /app/headphones/Headphones.py \
            --datadir=/config
