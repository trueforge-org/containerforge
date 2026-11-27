#!/usr/bin/env bash
set -euo pipefail

# Counter-Strike 1.6 (GoldSrc, Steam app 90) on hlds_run, installed with SteamCMD into /config.
# Caches and scratch go to /tmp.
export HOME=/config
export XDG_CACHE_HOME=/tmp
export TMPDIR=/tmp

APP_ID=90
STEAMCMD_DIR=/config/steamcmd
SERVER_DIR=/config/serverfiles
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-+maxplayers 32 +map de_dust}"
VALIDATE="${VALIDATE:-false}"

mkdir -p "${STEAMCMD_DIR}" "${SERVER_DIR}" /config/.steam/sdk32 /tmp/steam

# Seed the SteamCMD bootstrap only when it is missing (same approach as apps/steamcmd).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ ! -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        echo "Error: SteamCMD bootstrap not found in /usr/local/share/steamcmd." >&2
        exit 1
    fi
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    mkdir -p "${STEAMCMD_DIR}/linux32"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

# Install or update the server idempotently. Anonymous login only in this draft.
SCRIPT_FILE="$(mktemp /tmp/steamcmd-script.XXXXXX)"
trap 'rm -f "${SCRIPT_FILE}"' EXIT
{
    echo "@ShutdownOnFailedCommand 1"
    echo "login anonymous"
    echo "force_install_dir ${SERVER_DIR}"
    if [ "${VALIDATE}" = "true" ]; then
        echo "app_update ${APP_ID} validate"
    else
        echo "app_update ${APP_ID}"
    fi
    echo "quit"
} > "${SCRIPT_FILE}"

if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${SCRIPT_FILE}"; then
    echo "Error: SteamCMD failed to install or update app ${APP_ID}." >&2
    exit 1
fi
rm -f "${SCRIPT_FILE}"

# Steam client library for the server (upstream uses sdk32).
if [ ! -f /config/.steam/sdk32/steamclient.so ] && [ -d "${STEAMCMD_DIR}/linux32" ]; then
    cp -a "${STEAMCMD_DIR}/linux32/." /config/.steam/sdk32/
fi

# Launch from the server directory. The flags follow the upstream cstrike1.6 branch.
# UNVERIFIED: the server must listen on 0.0.0.0; confirm in the first boot log.
cd "${SERVER_DIR}"
read -r -a GAME_ARGS <<< "${GAME_PARAMS}"
exec ./hlds_run -game cstrike "${GAME_ARGS[@]}" -console +port "${GAME_PORT}"
