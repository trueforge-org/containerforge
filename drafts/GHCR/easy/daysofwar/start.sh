#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

export STEAM_APP_IDS="${STEAM_APP_IDS:-541790}"
export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"

# Values used by the server launch line once it is verified.
: "${GAME_PARAMS:=dow_cathedral}" "${GAME_PORT:=7777}" "${QUERY_PORT:=27015}"

mkdir -p "${STEAM_INSTALL_DIR}"

# Install or update through the base SteamCMD script (copied in the Dockerfile).
# It reads STEAM_APP_IDS, STEAM_INSTALL_DIR, STEAM_USERNAME and STEAM_PASSWORD.
# It is not exec'd, so this script continues after the install.
/usr/local/bin/steamcmd-base.sh +quit

# UNVERIFIED: the server binary and its arguments are not confirmed. The ich777
# start-server.sh was not fetched. Fill this in from the upstream file at build time.
echo "Error: the Days of War server launch line is not verified yet. SteamCMD install finished." >&2
exit 1
