#!/usr/bin/env bash
set -euo pipefail

GAME_DIR=/app
GAME_BIN="${GAME_DIR}/Quake3-UrT-Ded.x86_64"
GAME_PORT="${GAME_PORT:-27960}"
CONFIG_NAME="${CONFIG_NAME:-server.cfg}"
START_PARAMS="${START_PARAMS:-}"

# Only the server config and its state are written to /config. The game files stay read-only in /app.
mkdir -p /config/q3ut4

# Seed the server config only when it is missing. Never overwrite user state.
# UNVERIFIED: q3ut4/server_example.cfg is the path the upstream start-server.sh copies from.
if [[ ! -f "/config/q3ut4/${CONFIG_NAME}" ]]; then
    if [[ -f "${GAME_DIR}/q3ut4/server_example.cfg" ]]; then
        cp "${GAME_DIR}/q3ut4/server_example.cfg" "/config/q3ut4/${CONFIG_NAME}"
    else
        : > "/config/q3ut4/${CONFIG_NAME}"
    fi
fi

# Split START_PARAMS into words without letting the shell expand them.
read -r -a extra_params <<< "${START_PARAMS}"

cd "${GAME_DIR}"

# UNVERIFIED: net_ip 0.0.0.0 (bind to all interfaces) is taken from the draft, and the exact flag must be checked against the ioq3 source.
# exec hands PID 1 to the server so signals reach it.
exec "${GAME_BIN}" \
    +set net_ip 0.0.0.0 \
    +set net_port "${GAME_PORT}" \
    +set fs_homepath /config \
    +exec "${CONFIG_NAME}" \
    "${extra_params[@]}"
