#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

install_dir="${STEAM_INSTALL_DIR:-/config/pavlovvr}"
app_id="${STEAM_APP_IDS:-622970}"

# 1. Install or update the server with the SteamCMD wrapper copied from the base image.
#    It exits the shell it runs in when SteamCMD ends, so run it in a subshell to keep this script going.
#    Setting STEAMCMD_PRE_UPDATE=false skips the base's self-update step.
if ! (
    STEAMCMD_PRE_UPDATE=false \
    STEAM_APP_IDS="${app_id}" \
    STEAM_INSTALL_DIR="${install_dir}" \
    STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}" \
    /usr/local/share/steamcmd/steamcmd-init.sh +quit
); then
    echo "Error: SteamCMD failed to install or update app ${app_id} into ${install_dir}." >&2
    exit 1
fi

# 2. Launch the server.
# UNVERIFIED: the launch script name, its flags and the bind address are not confirmed yet
# (the Pavlov docs and the installed tree were not checked). Until they are, fail clearly
# instead of guessing. Once confirmed, replace this block with an `exec` of the server so
# signals reach it as PID 1.
echo "Error: the Pavlov server launch command is not verified yet. Installed files are in ${install_dir}." >&2
exit 1
