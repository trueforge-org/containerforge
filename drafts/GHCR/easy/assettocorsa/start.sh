#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles

mkdir -p /config/steamcmd "${SERVER_DIR}"

# Seed SteamCMD into /config on first start. It self-updates, so it cannot run from the read-only /usr tree.
# This script is /start.sh in the image, so it does not call /usr/local/bin/steamcmd (that wrapper execs /start.sh).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

cd /config/steamcmd

# Install or update the dedicated server with anonymous login.
steam_args=(+force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${GAME_ID}")
if [ "${VALIDATE:-false}" = "true" ]; then
    steam_args+=(validate)
fi
steam_args+=(+quit)
"${STEAMCMD_DIR}/steamcmd.sh" "${steam_args[@]}"

# UNVERIFIED: the server binary name (acServer) and its config files (cfg/server_cfg.ini, cfg/entry_list.ini).
# Seed the config files only when missing once the layout is confirmed in a run.
cd "${SERVER_DIR}"
if [ ! -x ./acServer ]; then
    echo "Error: acServer not found in ${SERVER_DIR} after SteamCMD update." >&2
    exit 1
fi
exec ./acServer
