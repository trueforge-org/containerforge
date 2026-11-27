#!/usr/bin/env bash
set -euo pipefail

# runtime state (SteamCMD, depot cache) goes to /tmp, the server install and saves to /config
export HOME=/tmp
export XDG_DATA_HOME=/tmp
export XDG_CACHE_HOME=/tmp/cache

SERVER_DIR=/config/valheim
SAVE_DIR=/config/worlds_local

mkdir -p "${SERVER_DIR}" "${SAVE_DIR}" /tmp/cache

STEAMCMD_ARGS="${STEAMCMD_ARGS:-validate}"
# downloads the dedicated server on first start and updates it on later starts
/usr/games/steamcmd +force_install_dir "${SERVER_DIR}" +login anonymous +app_update 896660 ${STEAMCMD_ARGS} +quit

cd "${SERVER_DIR}" || exit 1
# UNVERIFIED: SteamAppId for the runtime library; confirm on the first live run
export SteamAppId=892970
export LD_LIBRARY_PATH="${SERVER_DIR}/linux64:${LD_LIBRARY_PATH:-}"

args=(-nographics -batchmode -name "${SERVER_NAME:-My Server}" -port "${SERVER_PORT:-2456}" -world "${WORLD_NAME:-Dedicated}" -savedir "${SAVE_DIR}")
if [[ "${SERVER_PUBLIC:-true}" == "true" ]]; then
  args+=(-public 1)
else
  args+=(-public 0)
fi
# Valheim only accepts the password as an argument, so it is visible in the process list (upstream limitation)
if [[ -n "${SERVER_PASS:-}" ]]; then
  args+=(-password "${SERVER_PASS}")
fi

exec ./valheim_server.x86_64 "${args[@]}"
