#!/usr/bin/env bash
set -euo pipefail

# NOTE: this file replaces /start.sh of the apps/steamcmd base. The base's /usr/local/bin/steamcmd
# wrapper calls /start.sh, so it no longer works as steamcmd. This script calls SteamCMD directly.

export HOME=/config
export DISPLAY=:99
export WINEPREFIX=/config/wine
export WINEDEBUG=-all

SERVER_DIR=/config/serverfiles
STEAMCMD=/usr/games/steamcmd
# UNVERIFIED: dedicated server app id (plan: 556450, not confirmed on a fetched page).
APP_ID=556450
# UNVERIFIED: server executable name and arguments, not confirmed on a fetched page.
SERVER_EXE="${SERVER_DIR}/TheForestDedicatedServer.exe"

mkdir -p /config/steamcmd "${SERVER_DIR}" "${WINEPREFIX}"

# Install or update the server files. VALIDATE=true adds the validate flag.
# UNVERIFIED: anonymous login is assumed to work for this app id.
UPDATE_CMD=(+force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${APP_ID}")
if [ "${VALIDATE:-true}" = "true" ]; then
  UPDATE_CMD+=(validate)
fi
"${STEAMCMD}" "${UPDATE_CMD[@]}" +quit

# Initialise the Wine prefix once, only when missing.
if [ ! -d "${WINEPREFIX}/drive_c" ]; then
  wineboot --init >/tmp/wineboot.log 2>&1 || true
fi

# Virtual display for Wine.
Xvfb "${DISPLAY}" -screen 0 1024x768x16 -nolisten tcp >/tmp/xvfb.log 2>&1 &
for _ in $(seq 1 50); do
  [ -S "/tmp/.X11-unix/X99" ] && break
  sleep 0.2
done

# Extra server arguments from GAME_PARAMS (split on whitespace).
read -r -a GAME_ARGS <<< "${GAME_PARAMS:-}"

# Final long-running process: the Windows server under Wine.
exec wine "${SERVER_EXE}" -batchmode -nographics "${GAME_ARGS[@]}"
