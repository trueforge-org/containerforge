#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

# Steam app 232330 is Counter-Strike: Source dedicated server (UNVERIFIED on the Steam store page).
GAME_ID=232330
STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles

mkdir -p /config/steamcmd "${SERVER_DIR}"

# Seed SteamCMD into /config on first start. It self-updates, so it cannot run from the read-only /usr tree.
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

cd /config/steamcmd

# Install or update the server with anonymous login. Account login is not supported in this draft.
steam_args=(+force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${GAME_ID}")
if [ "${VALIDATE:-false}" = "true" ]; then
    steam_args+=(validate)
fi
steam_args+=(+quit)
"${STEAMCMD_DIR}/steamcmd.sh" "${steam_args[@]}"

# SteamClient library the server loads from ~/.steam/sdk32 (as the upstream start-server.sh does).
if [ ! -f /config/.steam/sdk32/steamclient.so ] && [ -d "${STEAMCMD_DIR}/linux32" ]; then
    mkdir -p /config/.steam/sdk32
    cp -f "${STEAMCMD_DIR}/linux32/"* /config/.steam/sdk32/
fi

cd "${SERVER_DIR}"
if [ ! -x ./srcds_run ]; then
    echo "Error: srcds_run not found in ${SERVER_DIR} after SteamCMD update." >&2
    exit 1
fi

# srcds_run sets its own library path (UNVERIFIED, confirm in a run).
read -r -a game_params <<< "${GAME_PARAMS:-}"
exec ./srcds_run -game cstrike "${game_params[@]}" -console +port "${GAME_PORT:-27015}"
