#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

SERVER_DIR=/config/serverfiles
STEAMCMD_DIR=/config/Steam/steamcmd
GAME_ID="${GAME_ID:-740}"
GAME_NAME="${GAME_NAME:-csgo}"
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-}"
VALIDATE="${VALIDATE:-false}"

if ! [[ "${GAME_ID}" =~ ^[0-9]+$ ]]; then
  echo "Error: GAME_ID must be numeric, got '${GAME_ID}'." >&2
  exit 1
fi

mkdir -p "${SERVER_DIR}" /config/steamcmd /config/.steam/sdk32

# Seed SteamCMD into /config when missing. SteamCMD self-updates, so it cannot run from /usr.
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
  mkdir -p "${STEAMCMD_DIR}/linux32"
  cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
  if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
    cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
  fi
fi

# Install or update the server. Anonymous login is used; the server is not a Steam account.
UPDATE_ARGS=(+force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${GAME_ID}")
if [ "${VALIDATE}" = "true" ]; then
  UPDATE_ARGS+=(validate)
fi
UPDATE_ARGS+=(+quit)

if ! "${STEAMCMD_DIR}/steamcmd.sh" "${UPDATE_ARGS[@]}"; then
  echo "Error: SteamCMD failed to install app ${GAME_ID}." >&2
  exit 1
fi

# Client library the server loads at runtime. Copy only when missing, so existing files are kept.
if [ ! -f /config/.steam/sdk32/steamclient.so ] && [ -f "${STEAMCMD_DIR}/linux32/steamclient.so" ]; then
  cp "${STEAMCMD_DIR}/linux32/steamclient.so" /config/.steam/sdk32/
fi

read -r -a PARAMS <<< "${GAME_PARAMS}"

cd "${SERVER_DIR}"
exec ./srcds_run -game "${GAME_NAME}" "${PARAMS[@]}" -console +port "${GAME_PORT}"
