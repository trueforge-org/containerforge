#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles

# UNVERIFIED: the dedicated-server Steam app ID is not confirmed (store app 1635450 is the client page).
# Set it in settings.yaml only after confirmation. Refuse to run without it.
APP_ID="${STEAM_APP_IDS:-}"
if [ -z "${APP_ID}" ]; then
    echo "Error: the Longvinter dedicated-server Steam app ID is not confirmed yet (STEAM_APP_IDS is empty)." >&2
    exit 1
fi

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

# UNVERIFIED: the server binary, its arguments, and any config file layout are not confirmed.
echo "Error: the Longvinter server launch command is not configured yet." >&2
exit 1
