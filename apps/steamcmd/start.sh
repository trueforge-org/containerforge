#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

mkdir -p /config/steamcmd

if [ ! -f /config/Steam/steamcmd/steamcmd.sh ]; then
    mkdir -p /config/Steam/steamcmd/linux32
    cp /usr/lib/games/steam/steamcmd.sh /config/Steam/steamcmd/
    cp /usr/lib/games/steam/steamcmd /config/Steam/steamcmd/linux32/
fi

cd /config/steamcmd

if [ -n "${STEAM_APP_IDS:-}" ] && [ "${STEAMCMD_SKIP_APP_UPDATE:-false}" != "true" ]; then
    STEAM_LOGIN_USER="${STEAM_USER:-anonymous}"
    STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"
    STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/steamapps}"
    mkdir -p "${STEAM_INSTALL_DIR}"

    CMD_ARGS=(+force_install_dir "${STEAM_INSTALL_DIR}")
    if [ "${STEAM_LOGIN_USER}" = "anonymous" ]; then
        CMD_ARGS=(+login anonymous "${CMD_ARGS[@]}")
    else
        CMD_ARGS=(+login "${STEAM_LOGIN_USER}" "${STEAM_LOGIN_PASSWORD}" "${CMD_ARGS[@]}")
    fi

    IFS=',' read -r -a APP_IDS <<< "${STEAM_APP_IDS}"
    for APP_ID in "${APP_IDS[@]}"; do
        APP_ID="${APP_ID//[[:space:]]/}"
        [ -z "${APP_ID}" ] && continue
        CMD_ARGS+=(+app_update "${APP_ID}")
        if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
            CMD_ARGS+=(validate)
        fi
    done
    CMD_ARGS+=(+quit)

    /config/Steam/steamcmd/steamcmd.sh "${CMD_ARGS[@]}"
fi

if [ -n "${STEAM_START_CMD:-}" ]; then
    exec sh -c "${STEAM_START_CMD}"
fi

exec /config/Steam/steamcmd/steamcmd.sh "$@"
