#!/usr/bin/env bash
set -euo pipefail

GAME_APP_ID=1829350 # Steam app id of the V Rising dedicated server (default branch)
DATA_DIR=/config/vrising
SERVER_DIR="${DATA_DIR}/server"
STEAM_HOME=/tmp/steam-home # SteamCMD state stays out of /config

export HOME=/config
export WINEPREFIX=/tmp/wine
export WINEDEBUG=-all

mkdir -p "${DATA_DIR}/Settings" "${DATA_DIR}/Saves" "${SERVER_DIR}" "${STEAM_HOME}"

# Install or update the server. The first start downloads several GB.
# Settings: the server reads its defaults from its own folder and overrides from ${DATA_DIR}/Settings,
# so nothing is seeded here.
HOME="${STEAM_HOME}" /usr/games/steamcmd \
  +force_install_dir "${SERVER_DIR}" \
  +login anonymous \
  +app_update "${GAME_APP_ID}" \
  +quit

cd "${SERVER_DIR}"
# UNVERIFIED: Xvfb via xvfb-run is needed for Wine, and -persistentDataPath may need a Wine path. Check on the first run.
exec xvfb-run -a wine64 "${SERVER_DIR}/VRisingServer.exe" \
  -persistentDataPath "${DATA_DIR}" \
  -saveName "${SAVE_NAME:-world1}" \
  -gamePort "${GAME_PORT:-27015}" \
  -queryPort "${QUERY_PORT:-27016}"
