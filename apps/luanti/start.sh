#!/usr/bin/env bash


DATA_DIR="/config/.minetest"
if [[ ! -w /config ]] || ! mkdir -p \
    "${DATA_DIR}/games" \
    "${DATA_DIR}/mods" \
    "${DATA_DIR}/main-config"; then
    DATA_DIR="/tmp/.minetest"
    mkdir -p \
        "${DATA_DIR}/games" \
        "${DATA_DIR}/mods" \
        "${DATA_DIR}/main-config"
fi

if [[ ! -f "${DATA_DIR}/main-config/minetest.conf" ]]; then
    cp /defaults/minetest.conf "${DATA_DIR}/main-config/minetest.conf"
fi

if [[ ! -d "${DATA_DIR}/games/minimal" ]]; then
    cp -pr /defaults/games/* "${DATA_DIR}/games/"
fi

if [[ "${DATA_DIR}" == "/tmp/.minetest" ]]; then
    export HOME="/tmp"
fi
export MINETEST_GAME_PATH="${DATA_DIR}/games"

exec luantiserver --port 30000 \
        --config "${DATA_DIR}/main-config/minetest.conf" ${CLI_ARGS}
