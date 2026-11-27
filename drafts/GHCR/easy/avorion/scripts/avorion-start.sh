#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

# UNVERIFIED: Avorion Steam app id. Set it once confirmed on the Valve wiki or Steam store page; the script refuses to run until then.
AVORION_APP_ID="UNVERIFIED"
if ! [[ "${AVORION_APP_ID}" =~ ^[0-9]+$ ]]; then
  echo "Error: Avorion Steam app id is not verified yet; refusing to start." >&2
  exit 1
fi

STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
export STEAM_INSTALL_DIR
export STEAM_APP_IDS="${AVORION_APP_ID}"
mkdir -p "${STEAM_INSTALL_DIR}"

# Install or update the server through the base SteamCMD wrapper (it reads STEAM_APP_IDS and STEAM_INSTALL_DIR).
/start.sh +quit

# UNVERIFIED: server binary name and launch arguments; take them from the Avorion dedicated-server docs before merge.
SERVER_BIN="${STEAM_INSTALL_DIR}/UNVERIFIED-server-binary"
if [ ! -x "${SERVER_BIN}" ]; then
  echo "Error: Avorion server binary not found at ${SERVER_BIN} after SteamCMD install." >&2
  exit 1
fi

cd "${STEAM_INSTALL_DIR}"
exec "${SERVER_BIN}"
