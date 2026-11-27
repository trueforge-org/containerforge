#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR="/config/Steam/steamcmd"
SERVER_DIR="/config/serverfiles"
APP_ID="746200"

# Values used by the server launch line once it is verified.
: "${GAME_PARAMS:=Port=10027 QueryPort=10037 -log}"

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

if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${STEAM_SCRIPT}"; then
    rm -f "${STEAM_SCRIPT}"
    echo "Error: SteamCMD failed to install app ${APP_ID}." >&2
    exit 1
fi
rm -f "${STEAM_SCRIPT}"

# UNVERIFIED: the PostScriptum server launcher is not confirmed. The ich777 wrapper uses
# srcds_run, which is Source-specific. Read the real binary and arguments from the installed
# files in ${SERVER_DIR} and then replace this stop with an exec of that binary and ${GAME_PARAMS}.
echo "Error: the PostScriptum server launcher is not verified yet. SteamCMD install of app ${APP_ID} finished." >&2
exit 1
