#!/usr/bin/env bash
# Left 4 Dead dedicated server (Steam app 222840) on the ContainerForge steamcmd base.
# COPY . / replaces the base image's /start.sh, so this script installs SteamCMD and the game
# itself and does not call the base helper.
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

APP_ID=222840
STEAMCMD_DIR=/config/Steam/steamcmd
INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
GAME_PORT="${GAME_PORT:-27015}"
GAME_PARAMS="${GAME_PARAMS:-+maxplayers 4 +map l4d_farm04_barn}"

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

# Install or update the game. The script file lives in /tmp, which is ephemeral.
script_file="$(mktemp /tmp/steamcmd-script.XXXXXX)"
trap 'rm -f "${script_file}"' EXIT

{
  echo "@ShutdownOnFailedCommand 1"
  echo "login anonymous"
  echo "force_install_dir ${INSTALL_DIR}"
  if [ "${STEAM_APP_VALIDATE}" = "true" ]; then
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

# srcds needs the 32-bit steamclient libraries (the upstream wrapper does the same copy).
mkdir -p /config/.steam/sdk32
cp -f "${STEAMCMD_DIR}/linux32/"* /config/.steam/sdk32/ 2>/dev/null || true

# UNVERIFIED: srcds_run flags. -game and +port follow the ich777 l4d wrapper; -ip 0.0.0.0 is
# added so the server listens on all interfaces. Confirm both on the first run.
cd "${INSTALL_DIR}"
read -r -a game_args <<< "${GAME_PARAMS}"
exec ./srcds_run -game left4dead -ip 0.0.0.0 "${game_args[@]}" -console +port "${GAME_PORT}"
