#!/usr/bin/env bash
set -euo pipefail

# Craftopia dedicated server (Steam app 1670340), installed with SteamCMD into /config.
# Install and update are implemented. The launch step is blocked: the server binary
# and its arguments are UNVERIFIED, so this script refuses to start a guessed binary.

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

APP_ID=1670340
STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles
STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}"

mkdir -p "${SERVER_DIR}" /tmp/steam

# Seed the SteamCMD bootstrap only when it is missing (same approach as apps/steamcmd).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    if [ ! -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        echo "Error: SteamCMD bootstrap not found in /usr/local/share/steamcmd." >&2
        exit 1
    fi
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
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
    if [ "${STEAM_APP_VALIDATE}" = "true" ]; then
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

# UNVERIFIED (blocker): the steamclient.so copy to $HOME/.steam/sdk32 is not added until confirmed.

# UNVERIFIED (blocker): the Craftopia server binary and its arguments are not confirmed.
# Replace this block with `cd "${SERVER_DIR}"` and `exec <server binary> <args>` once verified.
echo "Error: Craftopia launch command is not verified yet. The server was installed to ${SERVER_DIR} but not started." >&2
exit 1
