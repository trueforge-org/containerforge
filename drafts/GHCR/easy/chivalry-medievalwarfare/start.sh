#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

GAME_ID="${GAME_ID:-220070}"
MAP="${MAP:-aocffa-moor_p}"
GAME_PARAMS="${GAME_PARAMS:-?port=7000?queryport=7010}"
GAME_PARAMS_EXTRA="${GAME_PARAMS_EXTRA:--seekfreeloadingserver}"
ADMIN_PWD="${ADMIN_PWD:-}"
VALIDATE="${VALIDATE:-false}"
SERVER_DIR=/config/serverfiles
BIN_DIR="${SERVER_DIR}/Binaries/Linux"

# Install or update through the SteamCMD wrapper kept from the base image (see Dockerfile).
# +quit stops it once the app update is done.
STEAM_APP_IDS="${GAME_ID}" STEAM_INSTALL_DIR="${SERVER_DIR}" STEAM_APP_VALIDATE="${VALIDATE}" \
  /usr/local/share/steamcmd/steamcmd-init.sh +quit

if [ ! -d "${BIN_DIR}" ]; then
  echo "Error: server binaries not found in ${BIN_DIR} after install." >&2
  exit 1
fi

# UNVERIFIED: steam_appid.txt (219640) and the steamclient.so copy come from the ich777 wrapper.
# Both are written only when missing, so user state is never overwritten.
if [ ! -f "${BIN_DIR}/steam_appid.txt" ]; then
  printf '%s\n' "219640" > "${BIN_DIR}/steam_appid.txt"
fi
mkdir -p "${BIN_DIR}/lib"
if [ ! -f "${BIN_DIR}/lib/steamclient.so" ] && [ -f /config/Steam/steamcmd/linux64/steamclient.so ]; then
  cp /config/Steam/steamcmd/linux64/steamclient.so "${BIN_DIR}/lib/"
fi

# Extra arguments are split into words without the shell, so they cannot inject commands.
read -r -a extra_args <<< "${GAME_PARAMS_EXTRA}"

cd "${BIN_DIR}"
# UNVERIFIED: the binary name and URL format come from the ich777 wrapper and are not confirmed for the
# current Steam build. ADMIN_PWD is passed on the command line because the server reads it from the URL;
# this makes it visible in the process list.
exec ./UDKGameServer-Linux "${MAP}?adminpassword=${ADMIN_PWD}?steamsockets${GAME_PARAMS}" "${extra_args[@]}"
