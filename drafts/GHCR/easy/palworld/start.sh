#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

install_dir="${STEAM_INSTALL_DIR:-/config/palworld}"

# Install or update the server through the SteamCMD wrapper kept from the base image (see Dockerfile).
# It reads STEAM_APP_IDS and STEAM_INSTALL_DIR; +quit stops it once the app update is done.
# The arguments must start with "+", otherwise the wrapper execs them directly.
STEAM_APP_IDS=2394010 STEAM_INSTALL_DIR="${install_dir}" \
  /usr/local/share/steamcmd/steamcmd-init.sh +quit

# UNVERIFIED: the PalServer.sh path and the launch flags come from the draft plan and are not confirmed
# against an installed tree. Check them on the first run.
cd "${install_dir}"
exec "${install_dir}/PalServer.sh" -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
