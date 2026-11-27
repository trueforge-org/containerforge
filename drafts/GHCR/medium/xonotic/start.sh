#!/usr/bin/env bash

mkdir -p /config/data

# seed server.cfg only when missing, never overwrite user state
if [[ ! -f /config/data/server.cfg ]]; then
    cp /defaults/server.cfg /config/data/server.cfg
fi

# UNVERIFIED: engine still reads game-dir data; writable-data remap (symlink or userdir) is open
cd /app/xonotic || exit 1
exec /app/xonotic/xonotic-linux64-dedicated "${GAME_PARAMS:-template}"
