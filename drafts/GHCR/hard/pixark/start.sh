#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export WINEPREFIX=/tmp/wine
export WINEDEBUG=-all
export XDG_RUNTIME_DIR=/tmp

APP_ID=824360
SERVER_DIR=/config/serverfiles
STEAM_DIR=/config/steamcmd
# UNVERIFIED: server executable path inside the SteamCMD install
SERVER_EXE="${SERVER_DIR}/PixarkServer.exe"

GAME_PARAMS="${GAME_PARAMS:-?MaxPlayers=10}"
GAME_PARAMS_EXTRA="${GAME_PARAMS_EXTRA:--QueryPort=27016 -Port=27015 -CubePort=27018 -NoBattlEye -nosteamclient -game -server -log}"
MAP="${MAP:-CubeWorld_Light}"
VALIDATE="${VALIDATE:-false}"

mkdir -p "${STEAM_DIR}" "${SERVER_DIR}" /tmp/wine

# install or update the server; validate only when requested
UPDATE_ARGS=()
if [ "${VALIDATE}" = "true" ]; then
    UPDATE_ARGS+=(validate)
fi
/usr/games/steamcmd +force_install_dir "${SERVER_DIR}" +login anonymous \
    +app_update "${APP_ID}" "${UPDATE_ARGS[@]}" +quit

# Wine needs a display
Xvfb :99 -screen 0 1024x768x16 >/tmp/xvfb.log 2>&1 &
export DISPLAY=:99

# UNVERIFIED: server launch arguments are not confirmed against a real server run
# TODO: SRV_PWD / SRV_ADMIN_PWD from the chart are not passed yet; add them once the server's
# argument format is confirmed, and keep them out of the process list if possible
exec wine "${SERVER_EXE}" "${MAP}${GAME_PARAMS}" ${GAME_PARAMS_EXTRA}
