#!/usr/bin/env bash

# DATA_PATH is where the lowdb JSON state is written (upstream default ./data/).
# UNVERIFIED: the web Configuration page may write a .env file into the app folder,
# which is read-only at runtime; check this before merging.
export DATA_PATH="${DATA_PATH:-/config/data/}"
mkdir -p "${DATA_PATH}"

cd /app/game-server-watcher || exit 1
exec node ./dist/server.js
