#!/usr/bin/env bash
set -euo pipefail

# Unturned dedicated server (Steam app 1110390), installed with SteamCMD into /config.
# Install and update follow apps/steamcmd. The launch line follows the upstream ich777
# unturned branch start-server.sh, which has not yet been confirmed by a run.

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

APP_ID=1110390
STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-}"
STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}"

mkdir -p "${SERVER_DIR}" /config/.steam/sdk64 /tmp/steam

# Seed the SteamCMD bootstrap only when it is missing.
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ ! -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        echo "Error: SteamCMD bootstrap not found in /usr/local/share/steamcmd." >&2
        exit 1
    fi
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

# Install or update the server. Anonymous login only in this draft.
SCRIPT_FILE="$(mktemp /tmp/steamcmd-script.XXXXXX)"
trap 'rm -f "${SCRIPT_FILE}"' EXIT
{
    echo "@ShutdownOnFailedCommand 1"
    echo "login anonymous"
    echo "force_install_dir ${SERVER_DIR}"
    if [ "${STEAM_APP_VALIDATE}" = "true" ]; then
        echo "app_update ${APP_ID} validate"
    else
        echo "app_update ${APP_ID}"
    fi
    echo "quit"
} > "${SCRIPT_FILE}"

if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${SCRIPT_FILE}"; then
    echo "Error: SteamCMD failed to install or update app ${APP_ID}." >&2
    exit 1
fi
rm -f "${SCRIPT_FILE}"

# Steam client library for the server (upstream unturned branch uses sdk64).
if [ ! -f /config/.steam/sdk64/steamclient.so ] && [ -f "${STEAMCMD_DIR}/linux64/steamclient.so" ]; then
    cp "${STEAMCMD_DIR}/linux64/steamclient.so" /config/.steam/sdk64/
fi

# UNVERIFIED: the upstream branch adds the Plugins/x86_64 directory to LD_LIBRARY_PATH.
export LD_LIBRARY_PATH="${SERVER_DIR}/Unturned_Headless_Data/Plugins/x86_64/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

# UNVERIFIED: the launcher name and flags come from the upstream unturned branch, not from a run.
# The server must listen on all interfaces; confirm on the first boot.
cd "${SERVER_DIR}"
read -r -a GAME_ARGS <<< "${GAME_PARAMS}"
exec ./Unturned_Headless.x86_64 -nographics "${GAME_ARGS[@]}" -port:"${GAME_PORT}" -sv
