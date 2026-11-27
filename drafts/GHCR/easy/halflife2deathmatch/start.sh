#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export STEAM_APP_IDS="${STEAM_APP_IDS:-232370}"
export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/steamapps}"

# Install or update the server with the base SteamCMD logic. A subshell is needed because the base
# script ends with exec, which would otherwise replace this script and the server would never start.
( /usr/local/bin/steamcmd-base.sh +quit )

cd "${STEAM_INSTALL_DIR}"
# UNVERIFIED: launch line follows the upstream start-server.sh pattern (srcds_run -game <game> ... +port).
# The hl2mp game name and the server binary location are not confirmed for this app.
exec ./srcds_run -game hl2mp -console +port 27015
