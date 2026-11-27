#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

GAME_PORT="${GAME_PORT:-7777}"
QUERY_PORT="${QUERY_PORT:-27015}"
BEACON_PORT="${BEACON_PORT:-15000}"
STEAM_APP_IDS="${STEAM_APP_IDS:-629800}"
STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}"
STEAM_LOGIN_USER="${STEAM_USERNAME:-anonymous}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"

if [[ "${STEAM_INSTALL_DIR}" =~ [[:space:]] ]]; then
  echo "ERROR: STEAM_INSTALL_DIR must not contain whitespace." >&2
  exit 1
fi

if [[ "${STEAM_LOGIN_USER}" != "anonymous" && -z "${STEAM_LOGIN_PASSWORD}" ]]; then
  echo "ERROR: STEAM_PASSWORD is required when using authenticated Steam login." >&2
  exit 1
fi

# Seed the SteamCMD launcher into /config only when missing.
if [[ ! -f /config/Steam/steamcmd/steamcmd.sh ]]; then
  mkdir -p /config/Steam/steamcmd/linux32
  cp /usr/local/share/steamcmd/steamcmd.sh /config/Steam/steamcmd/
fi

escape_steam_arg() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "${value}"
}

# Install or update the server. The script file goes to /tmp (chmod 600), so the
# password stays out of the process list and the logs.
STEAMCMD_TMP_DIR=/tmp/steamcmd
mkdir -p "${STEAMCMD_TMP_DIR}" "${STEAM_INSTALL_DIR}"
script_file="$(mktemp "${STEAMCMD_TMP_DIR}/steamcmd-script.XXXXXX")"
chmod 600 "${script_file}"
trap 'rm -f "${script_file}"' EXIT INT TERM

{
  echo "@ShutdownOnFailedCommand 1"
  if [[ "${STEAM_LOGIN_USER}" == "anonymous" ]]; then
    echo "login anonymous"
  else
    echo "login \"$(escape_steam_arg "${STEAM_LOGIN_USER}")\" \"$(escape_steam_arg "${STEAM_LOGIN_PASSWORD}")\""
  fi
  echo "force_install_dir ${STEAM_INSTALL_DIR}"
  for app_id in ${STEAM_APP_IDS//,/ }; do
    if ! [[ "${app_id}" =~ ^[0-9]+$ ]]; then
      echo "ERROR: invalid app id '${app_id}' in STEAM_APP_IDS." >&2
      exit 1
    fi
    if [[ "${STEAM_APP_VALIDATE}" == "true" ]]; then
      echo "app_update ${app_id} validate"
    else
      echo "app_update ${app_id}"
    fi
  done
  echo "quit"
} > "${script_file}"

if ! /config/Steam/steamcmd/steamcmd.sh +runscript "${script_file}"; then
  echo "ERROR: SteamCMD failed to install app(s): ${STEAM_APP_IDS}." >&2
  exit 1
fi

# UNVERIFIED: the server launcher path and its flags are not confirmed yet.
# Check the installed files under STEAM_INSTALL_DIR and update this line.
cd "${STEAM_INSTALL_DIR}"
if [[ ! -x ./MordhauServer.sh ]]; then
  echo "ERROR: server launcher not found at ${STEAM_INSTALL_DIR}/MordhauServer.sh" >&2
  exit 1
fi
exec ./MordhauServer.sh -Port="${GAME_PORT}" -QueryPort="${QUERY_PORT}" -BeaconPort="${BEACON_PORT}"
