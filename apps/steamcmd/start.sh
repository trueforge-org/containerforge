#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

mkdir -p /config/steamcmd

if [ ! -f /config/Steam/steamcmd/steamcmd.sh ]; then
    mkdir -p /config/Steam/steamcmd/linux32
    if [ -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        cp /usr/local/share/steamcmd/steamcmd.sh /config/Steam/steamcmd/
        if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
            cp /usr/local/share/steamcmd/linux32/steamcmd /config/Steam/steamcmd/linux32/
        fi
    elif [ -f /usr/lib/games/steam/steamcmd.sh ] && [ -f /usr/lib/games/steam/steamcmd ]; then
        cp /usr/lib/games/steam/steamcmd.sh /config/Steam/steamcmd/
        cp /usr/lib/games/steam/steamcmd /config/Steam/steamcmd/linux32/
    else
        echo "Error: Could not find steamcmd.sh in expected locations (/usr/local/share/steamcmd or /usr/lib/games/steam)." >&2
        exit 1
    fi
fi

cd /config/steamcmd

STEAM_LOGIN_USER="${STEAM_USERNAME:-${STEAM_USER:-anonymous}}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"

if [ "$#" -gt 0 ]; then
    case "${1}" in
        +*) ;;
        *) exec "$@" ;;
    esac
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
    script_file="$(mktemp "${TMPDIR:-/tmp}/steamcmd-script.XXXXXX")"
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

    /config/Steam/steamcmd/steamcmd.sh +runscript "${script_file}"
}

if [ "${STEAMCMD_PRE_UPDATE:-true}" = "true" ]; then
    if ! run_steamcmd_script; then
        if [ -n "${STEAM_APP_IDS:-}" ] && [ "${STEAMCMD_SKIP_APP_UPDATE:-false}" != "true" ]; then
            echo "Error: SteamCMD pre-update failed while app initialization is enabled. Check SteamCMD output above for details." >&2
            exit 1
        fi
        echo "Warning: SteamCMD pre-update failed; continuing because no app initialization was requested." >&2
    fi
fi

if [ -n "${STEAM_APP_IDS:-}" ] && [ "${STEAMCMD_SKIP_APP_UPDATE:-false}" != "true" ]; then
    STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/steamapps}"
    if [[ "${STEAM_INSTALL_DIR}" =~ [[:space:]] ]]; then
        echo "Error: STEAM_INSTALL_DIR must not contain whitespace." >&2
        exit 1
    fi
    mkdir -p "${STEAM_INSTALL_DIR}"

    CMD_ARGS=("force_install_dir ${STEAM_INSTALL_DIR}")

    IFS=',' read -r -a app_ids <<< "${STEAM_APP_IDS}"
    for app_id in "${app_ids[@]}"; do
        app_id="${app_id//[[:space:]]/}"
        [ -z "${app_id}" ] && continue
        if ! [[ "${app_id}" =~ ^[0-9]+$ ]]; then
            echo "Error: Invalid app id '${app_id}' in STEAM_APP_IDS. Only numeric IDs are supported." >&2
            exit 1
        fi
        APP_UPDATE_CMD="app_update ${app_id}"
        if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
            APP_UPDATE_CMD="${APP_UPDATE_CMD} validate"
        fi
        CMD_ARGS+=("${APP_UPDATE_CMD}")
    done

    if ! run_steamcmd_script "${CMD_ARGS[@]}"; then
        echo "Error: Failed to initialize Steam app(s): ${STEAM_APP_IDS}. Check SteamCMD output above for details." >&2
        exit 1
    fi
fi

exec /config/Steam/steamcmd/steamcmd.sh "$@"
