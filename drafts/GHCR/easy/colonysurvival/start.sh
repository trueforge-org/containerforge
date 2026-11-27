#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CACHE_HOME=/tmp
export TMPDIR=/tmp

STEAM_APP_ID=748090
STEAMCMD_DIR="/config/Steam/steamcmd"
SERVER_DIR="/config/serverfiles"

mkdir -p "${STEAMCMD_DIR}/linux32" "${SERVER_DIR}" /tmp/steam

# Seed the writable SteamCMD copy only when it is missing (it self-updates in place).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ ! -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        echo "Error: steamcmd.sh not found in the image." >&2
        exit 1
    fi
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

# Install or update the server. Anonymous login only: no password is passed.
UPDATE_ARGS=(+force_install_dir "${SERVER_DIR}" +login anonymous)
if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
    UPDATE_ARGS+=(+app_update "${STEAM_APP_ID}" validate)
else
    UPDATE_ARGS+=(+app_update "${STEAM_APP_ID}")
fi
UPDATE_ARGS+=(+quit)

"${STEAMCMD_DIR}/steamcmd.sh" "${UPDATE_ARGS[@]}"

cd "${SERVER_DIR}"

# UNVERIFIED: the Colony Survival server executable, its arguments and the UDP game port (27016)
# are not confirmed on any fetched page. The chart passes "+server.gameport 27016", which is also unconfirmed.
# Fail closed until the first real run confirms the launch command.
echo "Error: the server launch command is not confirmed for this image yet." >&2
exit 1
