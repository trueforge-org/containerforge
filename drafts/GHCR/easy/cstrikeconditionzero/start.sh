#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CACHE_HOME=/tmp
export TMPDIR=/tmp

STEAM_APP_ID=90                       # CS:CZ dedicated server (UNVERIFIED, see plan section 10.1)
STEAM_MOD="czero"
STEAMCMD_DIR="/config/steamcmd"
SERVER_DIR="/config/serverfiles"
STEAM_LOGIN_USER="${STEAM_USERNAME:-anonymous}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:--secure +maxplayers 32 +map as_oilrig}"
STEAMCMD_TMP_DIR="/tmp/steamcmd"

mkdir -p "${STEAMCMD_DIR}/linux32" "${SERVER_DIR}" "${STEAMCMD_TMP_DIR}"

# Seed the writable SteamCMD copy only when it is missing (it self-updates in place).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    elif [ -f /usr/lib/games/steam/steamcmd.sh ]; then
        cp /usr/lib/games/steam/steamcmd.sh "${STEAMCMD_DIR}/"
    else
        echo "Error: steamcmd.sh not found in the image." >&2
        exit 1
    fi
    if [ -f /usr/lib/games/steam/steamcmd ]; then
        cp /usr/lib/games/steam/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

if [ "$#" -gt 0 ]; then
    case "${1}" in
        +*) ;;
        *) exec "$@" ;;
    esac
fi

escape_steam_arg() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '%s' "${value}"
}

# Run SteamCMD from a script file so the password is not on the command line.
run_steamcmd_script() {
    local script_file
    script_file="$(mktemp "${STEAMCMD_TMP_DIR}/steamcmd-script.XXXXXX")"
    chmod 600 "${script_file}"
    trap 'rm -f "${script_file}"' RETURN

    {
        echo "@ShutdownOnFailedCommand 1"
        if [ "${STEAM_LOGIN_USER}" = "anonymous" ]; then
            echo "login anonymous"
        else
            echo "login \"$(escape_steam_arg "${STEAM_LOGIN_USER}")\" \"$(escape_steam_arg "${STEAM_LOGIN_PASSWORD}")\""
        fi
        for cmd in "$@"; do
            echo "${cmd}"
        done
        echo "quit"
    } > "${script_file}"

    "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${script_file}"
}

# Self-update SteamCMD first.
run_steamcmd_script

# Install the mod setting, then install or update the server.
UPDATE_CMDS=(
    "force_install_dir ${SERVER_DIR}"
    "app_set_config ${STEAM_APP_ID} mod ${STEAM_MOD}"
)
if [ "${VALIDATE:-false}" = "true" ]; then
    UPDATE_CMDS+=("app_update ${STEAM_APP_ID} validate")
else
    UPDATE_CMDS+=("app_update ${STEAM_APP_ID}")
fi
run_steamcmd_script "${UPDATE_CMDS[@]}"

# UNVERIFIED: the location of steamclient.so differs between SteamCMD and the server files.
mkdir -p "${HOME}/.steam/sdk32"
if [ -f "${SERVER_DIR}/steamclient.so" ]; then
    cp -f "${SERVER_DIR}/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so"
elif [ -f "${STEAMCMD_DIR}/linux32/steamclient.so" ]; then
    cp -f "${STEAMCMD_DIR}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so"
fi

cd "${SERVER_DIR}"

# Word-split GAME_PARAMS into an array so it is never passed through eval.
read -r -a game_params <<< "${GAME_PARAMS}"

exec ./hlds_run -game czero "${game_params[@]}" -console +port "${GAME_PORT}"
