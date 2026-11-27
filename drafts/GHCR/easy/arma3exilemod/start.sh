#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAM_APP_IDS="${STEAM_APP_IDS:-233780}"
ARMA_DIR="/config/arma3exilemod"
GAME_PORT="${GAME_PORT:-2302}"

mkdir -p "${ARMA_DIR}"

# Seed the base config only when it is missing. Never overwrite user state.
if [ ! -f "${ARMA_DIR}/server.cfg" ]; then
    cp /defaults/server.cfg "${ARMA_DIR}/server.cfg"
fi

# Install or update the server with the base SteamCMD script (it runs app_update for STEAM_APP_IDS).
STEAM_APP_IDS="${STEAM_APP_IDS}" STEAM_INSTALL_DIR="${ARMA_DIR}" \
    /usr/local/bin/steamcmd-base.sh +quit

# UNVERIFIED: ExileMod install step. The source URL (EXILEMOD_SERVER_URL in the chart) and its
# license are not confirmed, so no download is done here yet.
# UNVERIFIED: database wait and password apply for the ExileMod database, pending the mariadb decision.

cd "${ARMA_DIR}"

if [ ! -x ./arma3server_x64 ]; then
    echo "Error: arma3server_x64 not found in ${ARMA_DIR} after install." >&2
    exit 1
fi

# UNVERIFIED: binary name and launch flags are not confirmed from upstream. Confirm against a real run.
exec ./arma3server_x64 -config=server.cfg -port="${GAME_PORT}"
