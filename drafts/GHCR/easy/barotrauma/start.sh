#!/usr/bin/env bash
# Barotrauma dedicated server (Steam app 1026340, from the TrueCharts chart) on the ContainerForge
# steamcmd base. COPY . / replaces the base image's /start.sh, so this script installs SteamCMD and
# the server itself and does not call the base helper.
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

APP_ID=1026340
STEAMCMD_DIR=/config/Steam/steamcmd
INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/barotrauma}"
GAME_PARAMS="${GAME_PARAMS:-}"

case "${INSTALL_DIR}" in
  *[[:space:]]*)
    echo "Error: STEAM_INSTALL_DIR must not contain whitespace." >&2
    exit 1
    ;;
esac

# Seed SteamCMD into /config once. The image ships it under /usr/local/share/steamcmd.
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
  mkdir -p "${STEAMCMD_DIR}/linux32"
  cp /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/steamcmd.sh"
  chmod 0755 "${STEAMCMD_DIR}/steamcmd.sh"
  if [ -f /usr/local/share/steamcmd/linux32/steamcmd ]; then
    cp /usr/local/share/steamcmd/linux32/steamcmd "${STEAMCMD_DIR}/linux32/steamcmd"
  fi
fi

mkdir -p "${INSTALL_DIR}"

# Install or update the server. The script file lives in /tmp, which is ephemeral.
script_file="$(mktemp /tmp/steamcmd-script.XXXXXX)"
trap 'rm -f "${script_file}"' EXIT

{
  echo "@ShutdownOnFailedCommand 1"
  echo "login anonymous"
  echo "force_install_dir ${INSTALL_DIR}"
  if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
    echo "app_update ${APP_ID} validate"
  else
    echo "app_update ${APP_ID}"
  fi
  echo "quit"
} > "${script_file}"

if ! "${STEAMCMD_DIR}/steamcmd.sh" +runscript "${script_file}"; then
  echo "Error: SteamCMD failed to install app ${APP_ID}. Check the output above." >&2
  exit 1
fi

# UNVERIFIED: the server binary name and its arguments. DedicatedServer is assumed from the Barotrauma
# Linux install and is not confirmed. Check the installed tree on the first run.
cd "${INSTALL_DIR}"
read -r -a game_args <<< "${GAME_PARAMS}"
exec ./DedicatedServer "${game_args[@]}"
