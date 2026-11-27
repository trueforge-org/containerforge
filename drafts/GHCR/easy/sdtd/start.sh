#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: Steam app id 294420 comes from the TrueCharts and ich777 configs, not from Steam (plan.md section 1).
STEAM_APP_IDS="${STEAM_APP_IDS:-294420}"
STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/steamapps}"
STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAMCMD_DIR=/config/Steam/steamcmd
# UNVERIFIED: server binary name inside the install directory.
SERVER_BIN="${STEAM_INSTALL_DIR}/7DaysToDieServer.x86_64"

export HOME=/config
export XDG_DATA_HOME=/config

if [[ "${STEAM_INSTALL_DIR}" =~ [[:space:]] ]]; then
    echo "Error: STEAM_INSTALL_DIR must not contain whitespace." >&2
    exit 1
fi

escape_steam_arg() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '%s' "${value}"
}

# Seed SteamCMD into /config only when it is missing (same layout as apps/steamcmd).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    mkdir -p "${STEAMCMD_DIR}/linux32"
    if [ ! -f /usr/local/share/steamcmd/steamcmd.sh ]; then
        echo "Error: SteamCMD not found in /usr/local/share/steamcmd." >&2
        exit 1
    fi
    cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
    if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
        cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
    fi
fi

# Install the server only when its binary is missing. Later starts skip the download.
if [ ! -x "${SERVER_BIN}" ]; then
    mkdir -p "${STEAM_INSTALL_DIR}"
    script_file="$(mktemp /tmp/steamcmd-script.XXXXXX)"
    chmod 600 "${script_file}"

    {
        echo "@ShutdownOnFailedCommand 1"
        if [ "${STEAM_USERNAME}" = "anonymous" ]; then
            echo "login anonymous"
        else
            if [ -z "${STEAM_PASSWORD:-}" ]; then
                echo "Error: STEAM_PASSWORD is required for a non-anonymous login." >&2
                exit 1
            fi
            echo "login \"$(escape_steam_arg "${STEAM_USERNAME}")\" \"$(escape_steam_arg "${STEAM_PASSWORD}")\""
        fi
        echo "force_install_dir ${STEAM_INSTALL_DIR}"

        IFS=',' read -r -a app_ids <<< "${STEAM_APP_IDS}"
        for app_id in "${app_ids[@]}"; do
            app_id="${app_id//[[:space:]]/}"
            [ -z "${app_id}" ] && continue
            if ! [[ "${app_id}" =~ ^[0-9]+$ ]]; then
                echo "Error: invalid app id '${app_id}' in STEAM_APP_IDS." >&2
                exit 1
            fi
            echo "app_update ${app_id} validate"
        done
        echo "quit"
    } > "${script_file}"

    "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${script_file}"
    rm -f "${script_file}"
fi

if [ ! -x "${SERVER_BIN}" ]; then
    echo "Error: server binary not found at ${SERVER_BIN} after install." >&2
    exit 1
fi

# UNVERIFIED: launch arguments and the config file name.
# Not done yet (plan.md section 7): writing the telnet and web admin passwords into the server config when it is missing.
cd "${STEAM_INSTALL_DIR}"
exec "${SERVER_BIN}" -configfile=serverconfig.xml
