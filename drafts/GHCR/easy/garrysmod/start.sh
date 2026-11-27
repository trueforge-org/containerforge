#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR="/config/Steam/steamcmd"
SERVER_DIR="/config/serverfiles"
# UNVERIFIED: app 4020 is taken from the store URL. Not confirmed as the dedicated server app.
APP_ID="4020"
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-+map gm_flatgrass +maxplayers 16}"

STEAM_LOGIN_USER="${STEAM_USERNAME:-anonymous}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"

if [ "${STEAM_LOGIN_USER}" != "anonymous" ] && [ -z "${STEAM_LOGIN_PASSWORD}" ]; then
    echo "Error: STEAM_PASSWORD is required when STEAM_USERNAME is not anonymous." >&2
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

escape_steam_arg() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '%s' "${value}"
}

# The password goes in a 0600 file under /tmp, not on the command line. It is removed after the run.
STEAM_SCRIPT="$(mktemp /tmp/steamcmd-script.XXXXXX)"
{
    echo "@ShutdownOnFailedCommand 1"
    if [ "${STEAM_LOGIN_USER}" = "anonymous" ]; then
        echo "login anonymous"
    else
        echo "login \"$(escape_steam_arg "${STEAM_LOGIN_USER}")\" \"$(escape_steam_arg "${STEAM_LOGIN_PASSWORD}")\""
    fi
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

cd "${SERVER_DIR}"
if [ ! -x ./srcds_run ]; then
    echo "Error: ${SERVER_DIR}/srcds_run not found after the install." >&2
    exit 1
fi

# UNVERIFIED: srcds_run path, -game name and arguments are not confirmed for this server layout.
read -r -a GAME_ARGS <<< "${GAME_PARAMS}"
exec ./srcds_run -game garrysmod "${GAME_ARGS[@]}" -console -port "${GAME_PORT}"
