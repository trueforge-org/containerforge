#!/usr/bin/env bash
set -euo pipefail

: "${INSTANCE_NAME:=SpaceEngineers}"
export WINEPREFIX="${WINEPREFIX:-/config/wineprefix}"
GAME_DIR=/config/SpaceEngineersDedicated
INSTANCE_DIR="/config/instances/${INSTANCE_NAME}"

mkdir -p "${GAME_DIR}" /config/instances /config/plugins "${INSTANCE_DIR}"

# Install or update the dedicated server (Steam app 298740) with anonymous login. Several GB on first start.
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "${GAME_DIR}" \
  +login anonymous +app_update 298740 validate +quit

# Create the Wine prefix once. UNVERIFIED: the upstream image runs a winetricks script whose components
# are unknown. Add them here once confirmed.
if [[ ! -f "${WINEPREFIX}/.initialised" ]]; then
  xvfb-run -a wineboot --init
  touch "${WINEPREFIX}/.initialised"
fi

# Plugins: copy from /config/plugins into the game dir on each start. UNVERIFIED target folder.
if compgen -G "/config/plugins/*" >/dev/null; then
  mkdir -p "${GAME_DIR}/Plugins"
  cp -a /config/plugins/. "${GAME_DIR}/Plugins/"
fi

# TODO(UNVERIFIED): apply PUBLIC_IP to the instance config once its file layout is confirmed.
PUBLIC_IP="${PUBLIC_IP:-}"

# UNVERIFIED: the exe location and the -noconsole/-ignorelastsession/-path flags come from community guides,
# not the upstream entrypoint, which could not be read. Check them against the upstream image.
cd "${GAME_DIR}"
exec wine "${GAME_DIR}/DedicatedServer64/SpaceEngineersDedicated.exe" \
  -noconsole -ignorelastsession -path "Z:\\config\\instances\\${INSTANCE_NAME}"
