#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles
APP_ID=443030

mkdir -p "${SERVER_DIR}" /tmp/steam

# Seed SteamCMD into /config only when it is missing (same approach as apps/steamcmd/start.sh).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp -L /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/steamcmd.sh"
fi

CMD_ARGS=(+force_install_dir "${SERVER_DIR}" +login anonymous)
if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
    CMD_ARGS+=(+app_update "${APP_ID}" validate)
else
    CMD_ARGS+=(+app_update "${APP_ID}")
fi
CMD_ARGS+=(+quit)

cd "${STEAMCMD_DIR}"
"${STEAMCMD_DIR}/steamcmd.sh" "${CMD_ARGS[@]}"

# UNVERIFIED: the Conan Exiles Linux server binary, its arguments and its bind/port settings are not confirmed.
# Do not use the srcds_run line from the ich777 wrapper; it is Source-engine specific.
echo "Error: the Conan Exiles server launch command is not configured yet." >&2
exit 1
