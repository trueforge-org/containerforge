#!/bin/bash
set -euo pipefail

# Runtime scratch in /tmp (read-only rootfs); game files persist in /config.
export HOME=/tmp/home
export XDG_CACHE_HOME=/tmp/.cache
export WINEPREFIX=/tmp/wine
export WINEDEBUG=-all
export DISPLAY=:99

SERVER_DIR="${SERVER_DIR:-/config/serverfiles}"
GAME_ID="${GAME_ID:-2465200}"
VALIDATE="${VALIDATE:-}"
GAME_PARAMS="${GAME_PARAMS:-}"

mkdir -p "${HOME}" "${XDG_CACHE_HOME}" "${WINEPREFIX}" "${SERVER_DIR}"

validate_arg=""
if [ "${VALIDATE}" = "true" ]; then
  validate_arg="validate"
fi

# UNVERIFIED: steamcmd self-update may need a writable install dir; check on first run
# shellcheck disable=SC2086
/usr/games/steamcmd +force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${GAME_ID}" ${validate_arg} +quit

# Wine needs an X display; Xvfb runs in the background and is not supervised.
Xvfb "${DISPLAY}" -screen 0 1024x768x16 -nolisten tcp >/tmp/xvfb.log 2>&1 &

cd "${SERVER_DIR}"
# UNVERIFIED: server executable name and launch flags are not confirmed against the game files
# shellcheck disable=SC2086
exec wine64 SonsOfTheForestDS.exe -batchmode -nographics ${GAME_PARAMS}
