#!/usr/bin/env bash
# Unresolved: the MistServer command line takes the vendor keys as arguments, so they
# are visible in the process list. Upstream (ich777) does the same; no env option known.
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

GAME_ID="${GAME_ID:-920720}"
IDENTIFIER="${IDENTIFIER:-dockeroasis_1}"
SLOTS="${SLOTS:-20}"
BACKENDAPIURLOVERRIDE="${BACKENDAPIURLOVERRIDE:-backend.last-oasis.com}"
GAME_PARAMS="${GAME_PARAMS:--port=5555 -QueryPort=27015 -NoLiveServer -EnableCheats}"
SERVER_DIR=/config/serverfiles

if ! [[ "${GAME_ID}" =~ ^[0-9]+$ ]]; then
    echo "Error: GAME_ID must be numeric." >&2
    exit 1
fi
mkdir -p "${SERVER_DIR}" /config/.steam/sdk64

# Install or update the server through the SteamCMD base image wrapper.
VALIDATE_FLAG=false
[ "${VALIDATE:-false}" = "true" ] && VALIDATE_FLAG=true
STEAM_APP_IDS="${GAME_ID}" STEAM_INSTALL_DIR="${SERVER_DIR}" STEAM_APP_VALIDATE="${VALIDATE_FLAG}" \
    /usr/local/bin/steamcmd-init +quit

if [ -f /config/Steam/steamcmd/linux64/steamclient.so ] && [ ! -f /config/.steam/sdk64/steamclient.so ]; then
    cp /config/Steam/steamcmd/linux64/steamclient.so /config/.steam/sdk64/
fi

BIN_DIR="${SERVER_DIR}/Mist/Binaries/Linux"
if [ ! -d "${BIN_DIR}" ]; then
    echo "Error: ${BIN_DIR} not found; the Steam download did not provide a Linux server." >&2
    exit 1
fi
cd "${BIN_DIR}"
grep -qx "903950" steam_appid.txt 2>/dev/null || echo "903950" > steam_appid.txt

if [ -x ./MistServer ]; then
    BIN=./MistServer
elif [ -x ./MistServer-Linux-Shipping ]; then
    BIN=./MistServer-Linux-Shipping
else
    echo "Error: MistServer executable not found in ${BIN_DIR}." >&2
    exit 1
fi

if [ -z "${CUSTOMER_KEY:-}" ] || [ -z "${PROVIDER_KEY:-}" ]; then
    echo "Warning: CUSTOMER_KEY and PROVIDER_KEY are not set; the server cannot register with the Last Oasis backend." >&2
fi

# GAME_PARAMS is intentionally word-split into separate arguments.
# shellcheck disable=SC2086
exec "${BIN}" -log -force_steamclient_link -messaging \
    -backendapiurloverride="${BACKENDAPIURLOVERRIDE}" \
    -identifier="${IDENTIFIER}" \
    -CustomerKey="${CUSTOMER_KEY:-}" \
    -ProviderKey="${PROVIDER_KEY:-}" \
    -slots="${SLOTS}" \
    -overrideconnectionaddress ${GAME_PARAMS}
