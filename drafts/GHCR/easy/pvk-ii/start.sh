#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

STEAM_APP_ID=17575
SERVER_DIR=/config/serverfiles
STEAM_DIR=/config/steamcmd
STEAM_BIN=/config/Steam/steamcmd/steamcmd.sh

mkdir -p "${SERVER_DIR}" "${STEAM_DIR}" /config/Steam/steamcmd/linux32

# Bootstrap SteamCMD into /config, as apps/steamcmd does.
if [ ! -f "${STEAM_BIN}" ]; then
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAM_BIN}"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd /config/Steam/steamcmd/linux32/
    fi
fi

# Install or update the server. Validate only when requested.
update_args=(+force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${STEAM_APP_ID}")
if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
    update_args+=(validate)
fi
cd "${STEAM_DIR}"
"${STEAM_BIN}" "${update_args[@]}" +quit

# Split GAME_PARAMS on whitespace without eval, so env values are never run as shell code.
read -r -a game_params <<< "${GAME_PARAMS:--maxplayers 18 +map bt_island}"

cd "${SERVER_DIR}"
exec ./srcds_run -game pvkii "${game_params[@]}" -console +port "${GAME_PORT:-27015}"
