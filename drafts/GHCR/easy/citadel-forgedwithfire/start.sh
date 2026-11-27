#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

# The chart value carries a trailing space, so strip whitespace.
GAME_ID="${GAME_ID:-489650}"
GAME_ID="${GAME_ID//[[:space:]]/}"
GAME_PARAMS="${GAME_PARAMS:-}"
VALIDATE="${VALIDATE:-false}"

STEAM_BIN=/config/Steam/steamcmd/steamcmd.sh
STEAMCMD_DIR=/config/steamcmd
SERVER_DIR=/config/serverfiles

if ! [[ "${GAME_ID}" =~ ^[0-9]+$ ]]; then
    echo "Error: GAME_ID must be a numeric Steam app id." >&2
    exit 1
fi

mkdir -p "${STEAMCMD_DIR}" "${SERVER_DIR}"

# SteamCMD self-updates, so it runs from a writable copy, not from /usr.
if [ ! -f "${STEAM_BIN}" ]; then
    mkdir -p /config/Steam/steamcmd/linux32
    if [ -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        cp /usr/local/share/steamcmd/steamcmd.sh /config/Steam/steamcmd/
        if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
            cp /usr/local/share/steamcmd/linux32/steamcmd /config/Steam/steamcmd/linux32/
        fi
    else
        echo "Error: steamcmd.sh not found in /usr/local/share/steamcmd." >&2
        exit 1
    fi
fi

script_file="$(mktemp /tmp/steamcmd-script.XXXXXX)"
trap 'rm -f "${script_file}"' EXIT INT TERM
{
    echo "@ShutdownOnFailedCommand 1"
    echo "login anonymous"
    echo "force_install_dir ${SERVER_DIR}"
    if [ "${VALIDATE}" = "true" ]; then
        echo "app_update ${GAME_ID} validate"
    else
        echo "app_update ${GAME_ID}"
    fi
    echo "quit"
} > "${script_file}"

if ! "${STEAM_BIN}" +runscript "${script_file}"; then
    echo "Error: SteamCMD failed to install app ${GAME_ID}. Check the output above." >&2
    exit 1
fi
rm -f "${script_file}"

# UNVERIFIED: server binary path is from upstream start-server.sh (citadelfwf branch) and may have changed.
SERVER_BIN="${SERVER_DIR}/Citadel/Binaries/Linux/CitadelServer-Linux-Shipping"
if [ ! -x "${SERVER_BIN}" ]; then
    echo "Error: server binary not found at ${SERVER_BIN}." >&2
    exit 1
fi

export LD_LIBRARY_PATH="${SERVER_DIR}/linux64/:${LD_LIBRARY_PATH:-}"

cd "${SERVER_DIR}"

# Word-split the extra params into an array, so no shell expansion happens on them.
read -r -a game_params <<< "${GAME_PARAMS}"

exec "${SERVER_BIN}" "${game_params[@]}"
