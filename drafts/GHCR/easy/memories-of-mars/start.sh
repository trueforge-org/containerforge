#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

# UNVERIFIED: Steam app id is not confirmed yet. Empty means first start fails with the message below.
STEAM_APP_IDS="${STEAM_APP_IDS:-}"
STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/memories-of-mars}"
STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}"
STEAM_LOGIN_USER="${STEAM_USERNAME:-anonymous}"
STEAM_LOGIN_PASSWORD="${STEAM_PASSWORD:-}"
STEAMCMD_DIR=/config/Steam/steamcmd

if [ -z "${STEAM_APP_IDS}" ]; then
  echo "Error: STEAM_APP_IDS is required (Steam app ID of the Memories of Mars dedicated server)." >&2
  exit 1
fi

if ! [[ "${STEAM_APP_IDS}" =~ ^[0-9]+$ ]]; then
  echo "Error: STEAM_APP_IDS must be a numeric Steam app ID." >&2
  exit 1
fi

# Seed SteamCMD into /config when missing (same source as the steamcmd base).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
  mkdir -p "${STEAMCMD_DIR}/linux32"
  cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
  if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
    cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/"
  fi
fi

escape_steam_arg() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "${value}"
}

mkdir -p /tmp/steamcmd "${STEAM_INSTALL_DIR}"
script_file="$(mktemp /tmp/steamcmd/script.XXXXXX)"
trap 'rm -f "${script_file}"' EXIT
chmod 600 "${script_file}"

{
  echo "@ShutdownOnFailedCommand 1"
  if [ "${STEAM_LOGIN_USER}" = "anonymous" ]; then
    echo "login anonymous"
  else
    echo "login \"$(escape_steam_arg "${STEAM_LOGIN_USER}")\" \"$(escape_steam_arg "${STEAM_LOGIN_PASSWORD}")\""
  fi
  echo "force_install_dir \"${STEAM_INSTALL_DIR}\""
  if [ "${STEAM_APP_VALIDATE}" = "true" ]; then
    echo "app_update ${STEAM_APP_IDS} validate"
  else
    echo "app_update ${STEAM_APP_IDS}"
  fi
  echo "quit"
} > "${script_file}"

if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${script_file}"; then
  echo "Error: SteamCMD failed to install Steam app ${STEAM_APP_IDS}." >&2
  exit 1
fi

# UNVERIFIED: the server binary under ${STEAM_INSTALL_DIR} and its launch arguments are not confirmed.
# Replace this block with `exec` of the confirmed server command once known.
echo "Error: the Memories of Mars server launch command is not confirmed yet; app ${STEAM_APP_IDS} is installed in ${STEAM_INSTALL_DIR}." >&2
exit 1
