#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

STEAMCMD_DIR="${STEAMCMD_DIR:-/config/steamcmd}"
SERVER_DIR="${SERVER_DIR:-/config/serverfiles}"
GAME_ID="${GAME_ID:-730}"
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-}"
VALIDATE="${VALIDATE:-}"
STEAM_LOGIN_USER="${STEAM_USERNAME:-anonymous}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"

STEAM_BIN=/config/Steam/steamcmd/steamcmd.sh

mkdir -p "${STEAMCMD_DIR}" "${SERVER_DIR}"

# SteamCMD self-updates, so it must run from a writable copy, not from /usr.
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

if ! [[ "${GAME_ID}" =~ ^[0-9]+$ ]]; then
    echo "Error: GAME_ID must be a numeric Steam app id." >&2
    exit 1
fi

if [ "${STEAM_LOGIN_USER}" != "anonymous" ] && [ -z "${STEAM_LOGIN_PASSWORD}" ]; then
    echo "Error: STEAM_PASSWORD is required when using authenticated Steam login." >&2
    exit 1
fi

escape_steam_arg() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '%s' "${value}"
}

# Credentials go into a private script file, not onto the command line.
script_file="$(mktemp "/tmp/steamcmd-script.XXXXXX")"
trap 'rm -f "${script_file}"' EXIT INT TERM
{
    echo "@ShutdownOnFailedCommand 1"
    if [ "${STEAM_LOGIN_USER}" = "anonymous" ]; then
        echo "login anonymous"
    else
        echo "login \"$(escape_steam_arg "${STEAM_LOGIN_USER}")\" \"$(escape_steam_arg "${STEAM_LOGIN_PASSWORD}")\""
    fi
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

# Steam client libraries the server loads at runtime.
# UNVERIFIED: location of linux64/steamclient.so under the SteamCMD install.
mkdir -p /config/.steam/sdk64
for lib in /config/Steam/linux64/steamclient.so /config/Steam/linux64/*; do
    if [ -f "${lib}" ]; then
        cp -f "${lib}" /config/.steam/sdk64/
        break
    fi
done

CS2_BIN="${SERVER_DIR}/game/bin/linuxsteamrt64/cs2"
if [ ! -x "${CS2_BIN}" ]; then
    echo "Error: CS2 server binary not found at ${CS2_BIN}." >&2
    exit 1
fi

export LD_LIBRARY_PATH="${SERVER_DIR}/bin/linuxsteamrt64:${LD_LIBRARY_PATH:-}"
export USE_STEAM_RUNTIME=1

cd "${SERVER_DIR}"

# Word-split the extra params into an array, so no shell expansion happens on them.
read -r -a game_params <<< "${GAME_PARAMS}"

# UNVERIFIED: "-port" is the expected flag for the game port; confirm with "cs2 -help" in the build test.
exec "${CS2_BIN}" -dedicated -port "${GAME_PORT}" "${game_params[@]}"
