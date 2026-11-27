#!/usr/bin/env bash
set -euo pipefail

export HOME=/tmp

server_dir="/config/serverfiles"
mkdir -p "${server_dir}"

# Seed the server files from the image only when the binary is missing.
# Existing saves and config in /config are never overwritten.
if [ ! -x "${server_dir}/cs2d_dedicated" ]; then
    cp -a /app/counterstrike2d/. "${server_dir}/"
fi

cd "${server_dir}"
# GAME_PARAMS is word-split on purpose, as in the upstream launch line.
# UNVERIFIED: the server may bind a fixed address in its config. Check it reaches all interfaces.
exec ./cs2d_dedicated ${GAME_PARAMS:-}
