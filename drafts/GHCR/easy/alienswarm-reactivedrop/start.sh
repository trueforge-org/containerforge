#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

APP_ID=563560
GAME_NAME=reactivedrop
SERVER_DIR=/config/serverfiles
STEAMCMD_DIR=/config/Steam/steamcmd
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-+map lobby -maxplayers 4 +exec server.cfg}"
VALIDATE="${VALIDATE:-false}"
PASSWRD="${PASSWRD:-}"

mkdir -p "${SERVER_DIR}" "${STEAMCMD_DIR}/linux32" /tmp/steamcmd

# Seed the SteamCMD launcher into /config only when missing.
if [[ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]]; then
  cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/"
fi

# Install or update the server. The script goes to /tmp with mode 600.
script_file="$(mktemp /tmp/steamcmd/steamcmd-script.XXXXXX)"
chmod 600 "${script_file}"
{
  echo "@ShutdownOnFailedCommand 1"
  echo "login anonymous"
  echo "force_install_dir ${SERVER_DIR}"
  if [[ "${VALIDATE}" == "true" ]]; then
    echo "app_update ${APP_ID} validate"
  else
    echo "app_update ${APP_ID}"
  fi
  echo "quit"
} > "${script_file}"

if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${script_file}"; then
  rm -f "${script_file}"
  echo "ERROR: SteamCMD failed to install app ${APP_ID}." >&2
  exit 1
fi
rm -f "${script_file}"

# UNVERIFIED: launch line follows the ich777 steamcmd image (srcds_run). Confirm on a real install.
cd "${SERVER_DIR}"
if [[ ! -x ./srcds_run ]]; then
  echo "ERROR: ${SERVER_DIR}/srcds_run not found after install." >&2
  exit 1
fi

# Word-split GAME_PARAMS on purpose, without globbing.
read -r -a game_params <<< "${GAME_PARAMS}"
extra=()
# Known gap: a password passed as an argument is visible in the process list.
if [[ -n "${PASSWRD}" ]]; then
  extra+=(+sv_password "${PASSWRD}")
fi

exec ./srcds_run -game "${GAME_NAME}" "${game_params[@]}" -console +port "${GAME_PORT}" "${extra[@]}"
