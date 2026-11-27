#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles
APP_ID=203300

mkdir -p "${SERVER_DIR}" /tmp/steam

# Seed SteamCMD into /config only when it is missing (same approach as apps/steamcmd/start.sh).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp -L /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/steamcmd.sh"
fi

# Anonymous login. PASSWRD (Steam login) is not used yet in this draft.
CMD_ARGS=(+force_install_dir "${SERVER_DIR}" +login anonymous)
if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
    CMD_ARGS+=(+app_update "${APP_ID}" validate)
else
    CMD_ARGS+=(+app_update "${APP_ID}")
fi
CMD_ARGS+=(+quit)

cd "${STEAMCMD_DIR}"
"${STEAMCMD_DIR}/steamcmd.sh" "${CMD_ARGS[@]}"

# UNVERIFIED: the server binary name and the start-server.sh flow of the upstream wrapper were not fetched.
# GAME_PARAMS (chart: -port=7778 -SAP=8778 -SQP=27015 -aauregion=1 -log=Server.log) is passed through once the binary is known.
echo "Error: the America's Army: Proving Grounds server launch command is not configured yet." >&2
exit 1
