#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/stationeers}"
STEAM_APP_IDS="${STEAM_APP_IDS:-600760}"
GAME_PARAMS="${GAME_PARAMS:--difficulty easy -loadlatest Mars Mars}"

export STEAM_INSTALL_DIR STEAM_APP_IDS
mkdir -p "${STEAM_INSTALL_DIR}"

# Install or update the server through the base SteamCMD wrapper (it reads STEAM_APP_IDS and STEAM_INSTALL_DIR).
/start.sh +quit

# UNVERIFIED: server binary name and launch path; confirm from the ich777 start-server.sh before merge.
SERVER_BIN="${STEAM_INSTALL_DIR}/UNVERIFIED-server-binary"
if [ ! -x "${SERVER_BIN}" ]; then
  echo "Error: Stationeers server binary not found at ${SERVER_BIN} after SteamCMD install." >&2
  exit 1
fi

cd "${STEAM_INSTALL_DIR}"
# GAME_PARAMS is intentionally word-split into server arguments.
# shellcheck disable=SC2086
exec "${SERVER_BIN}" ${GAME_PARAMS}
