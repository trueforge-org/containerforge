#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR="/config/Steam/steamcmd"
SERVER_DIR="/config/serverfiles"
APP_ID="${STEAM_APP_IDS:-635}"
GAME_NAME="${GAME_NAME:-swarm}"
GAME_PARAMS="${GAME_PARAMS:-+map lobby -maxplayers 4 +exec server.cfg}"
GAME_PORT="${GAME_PORT:-27015}"

if ! [[ "${APP_ID}" =~ ^[0-9]+$ ]]; then
    echo "Error: STEAM_APP_IDS must be a numeric Steam app ID." >&2
    exit 1
fi

# Seed SteamCMD into /config once, as apps/steamcmd does.
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ ! -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        echo "Error: SteamCMD was not found in the base image." >&2
        exit 1
    fi
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

mkdir -p "${SERVER_DIR}"

# Login and app commands go in a 0600 file under /tmp, not on the command line.
STEAM_SCRIPT="$(mktemp /tmp/steamcmd-script.XXXXXX)"
{
    echo "@ShutdownOnFailedCommand 1"
    echo "login anonymous"
    echo "force_install_dir ${SERVER_DIR}"
    if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
        echo "app_update ${APP_ID} validate"
    else
        echo "app_update ${APP_ID}"
    fi
    echo "quit"
} > "${STEAM_SCRIPT}"

# Not exec'd: the script must still start the server after the install.
if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${STEAM_SCRIPT}"; then
    rm -f "${STEAM_SCRIPT}"
    echo "Error: SteamCMD failed to install app ${APP_ID}." >&2
    exit 1
fi
rm -f "${STEAM_SCRIPT}"

# UNVERIFIED: upstream also copies the linux32 libraries to .steam/sdk32. Not done here; check at build time.
cd "${SERVER_DIR}"
if [ ! -x ./srcds_run ]; then
    echo "Error: ${SERVER_DIR}/srcds_run not found after the install." >&2
    exit 1
fi

# UNVERIFIED: srcds_run launch line is taken from the ich777 wrapper start-server.sh.
read -r -a GAME_ARGS <<< "${GAME_PARAMS}"
exec ./srcds_run -game "${GAME_NAME}" "${GAME_ARGS[@]}" -console +port "${GAME_PORT}"
