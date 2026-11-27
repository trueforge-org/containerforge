#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAM_APP_IDS="${STEAM_APP_IDS:-258550}"
STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/steamapps}"
GAME_PARAMS="${GAME_PARAMS:-+server.maxplayers 10}"
GAME_PORT="${GAME_PORT:-28015}"

mkdir -p "${STEAM_INSTALL_DIR}"

# Install or update the server with the base SteamCMD script (it runs app_update for STEAM_APP_IDS).
STEAM_APP_IDS="${STEAM_APP_IDS}" STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR}" \
    /usr/local/bin/steamcmd-base.sh +quit

cd "${STEAM_INSTALL_DIR}"

# UNVERIFIED: the server binary name and launch flags are not confirmed from upstream.
# The chart passes GAME_PARAMS as +server.* settings. Confirm against a real run.
if [ ! -x ./RustDedicated ]; then
    echo "Error: RustDedicated not found in ${STEAM_INSTALL_DIR} after install." >&2
    exit 1
fi

# shellcheck disable=SC2086
exec ./RustDedicated -batchmode +server.port "${GAME_PORT}" ${GAME_PARAMS}
