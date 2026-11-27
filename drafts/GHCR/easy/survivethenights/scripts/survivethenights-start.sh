#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: the Steam dedicated server app ID is not confirmed. It must be passed at run time.
if [ -z "${STEAM_APP_IDS:-}" ]; then
    echo "Error: STEAM_APP_IDS is required (Steam dedicated server app ID)." >&2
    exit 1
fi

export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
export STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}"

# Install or update the app through the base start script. "+quit" makes the base run its
# app_update loop and then quit SteamCMD, instead of opening an interactive shell.
/start.sh +quit

# UNVERIFIED: the server binary name and its launch arguments are not fetched yet.
# Fail closed until the first real run confirms them.
echo "Error: the server start command is not confirmed for this image yet." >&2
exit 1
