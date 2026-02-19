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
    STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/steamapps}"
    mkdir -p "${STEAM_INSTALL_DIR}"

    CMD_ARGS=(+login anonymous +force_install_dir "${STEAM_INSTALL_DIR}")

    IFS=',' read -r -a app_ids <<< "${STEAM_APP_IDS}"
    for app_id in "${app_ids[@]}"; do
        app_id="${app_id//[[:space:]]/}"
        [ -z "${app_id}" ] && continue
        CMD_ARGS+=(+app_update "${app_id}")
        if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
            CMD_ARGS+=(validate)
        fi
    done
    CMD_ARGS+=(+quit)

    if ! /config/Steam/steamcmd/steamcmd.sh "${CMD_ARGS[@]}"; then
        echo "Error: Failed to initialize Steam app(s): ${STEAM_APP_IDS}. Check SteamCMD output above for details." >&2
        exit 1
    fi
fi

exec /config/Steam/steamcmd/steamcmd.sh "$@"
