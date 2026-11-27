#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

SERVER_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
VALIDATE="${VALIDATE:-false}"

# UNVERIFIED: 581330 is the server app id from the TrueCharts chart. Steam store data was not
# returned for it, so confirm it with SteamCMD (app_info_print 581330) before the first run.
# Install or update through the SteamCMD wrapper kept from the base image (see Dockerfile).
STEAM_APP_IDS=581330 STEAM_INSTALL_DIR="${SERVER_DIR}" STEAM_APP_VALIDATE="${VALIDATE}" \
  /usr/local/share/steamcmd/steamcmd-init.sh +quit

# UNVERIFIED: the Sandstorm server executable and its launch arguments are not confirmed yet.
# Replace this stop with the verified launch command (exec, so signals reach the server).
echo "Error: the Insurgency: Sandstorm server launch command is not verified yet." >&2
exit 1
