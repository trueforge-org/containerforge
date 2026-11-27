#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAM_APP_IDS="${STEAM_APP_IDS:-232290}"
STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
GAME_NAME="${GAME_NAME:-dod}"
GAME_PARAMS="${GAME_PARAMS:--secure +maxplayers 24 +map dod_kalt}"
GAME_PORT="${GAME_PORT:-27015}"

mkdir -p "${STEAM_INSTALL_DIR}"

# Install or update the game with the base SteamCMD script (it runs app_update for STEAM_APP_IDS).
STEAM_APP_IDS="${STEAM_APP_IDS}" STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR}" \
    /usr/local/bin/steamcmd-base.sh +quit

cd "${STEAM_INSTALL_DIR}"

if [ ! -x ./srcds_run ]; then
    echo "Error: srcds_run not found in ${STEAM_INSTALL_DIR} after install." >&2
    exit 1
fi

# Launch line taken from the upstream ich777 start-server.sh.
# UNVERIFIED: whether DoD:S needs the 32-bit steamclient libs under /config/.steam/sdk32.
# shellcheck disable=SC2086
exec ./srcds_run -game "${GAME_NAME}" ${GAME_PARAMS} -console +port "${GAME_PORT}"
