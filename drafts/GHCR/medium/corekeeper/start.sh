#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR="/config/steamcmd"
SERVER_DIR="/config/serverfiles"
STEAMCMD_TMP_DIR="/tmp/steamcmd"
# UNVERIFIED: Steam dedicated server app ID (taken from the TrueCharts chart).
GAME_ID="1963720"
# UNVERIFIED: server binary name and launch flags. Confirm from the installed files.
SERVER_BIN="${SERVER_DIR}/CoreKeeperServer"

STEAM_LOGIN_USER="${STEAM_USERNAME:-anonymous}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"
VALIDATE="${VALIDATE:-false}"

mkdir -p "${STEAMCMD_DIR}" "${SERVER_DIR}" "${STEAMCMD_TMP_DIR}"

# SteamCMD must run from a writable directory because it updates itself.
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    else
        echo "Error: steamcmd.sh not found in /usr/local/share/steamcmd." >&2
        exit 1
    fi
fi

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

if [ "${STEAM_LOGIN_USER}" != "anonymous" ] && [ -z "${STEAM_LOGIN_PASSWORD}" ]; then
    echo "Error: STEAM_PASSWORD is required when using authenticated Steam login." >&2
    exit 1
fi

escape_steam_arg() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '%s' "${value}"
}

run_steamcmd_script() {
    local script_file
    script_file="$(mktemp "${STEAMCMD_TMP_DIR}/steamcmd-script.XXXXXX")"
    chmod 600 "${script_file}"
    trap 'rm -f "${script_file}"' EXIT INT TERM

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

APP_UPDATE_CMD="app_update ${GAME_ID}"
if [ "${VALIDATE}" = "true" ]; then
    APP_UPDATE_CMD="${APP_UPDATE_CMD} validate"
fi

if ! run_steamcmd_script "force_install_dir ${SERVER_DIR}" "${APP_UPDATE_CMD}"; then
    echo "Error: SteamCMD failed to install or update app ${GAME_ID}. Check the output above." >&2
    exit 1
fi

if [ ! -x "${SERVER_BIN}" ]; then
    echo "Error: server binary not found at ${SERVER_BIN}." >&2
    exit 1
fi

cd "${SERVER_DIR}"
exec "${SERVER_BIN}" -batchmode
