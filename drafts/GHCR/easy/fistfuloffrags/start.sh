#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
export TMPDIR=/tmp

# UNVERIFIED: the dedicated server Steam app ID. The chart uses 295230, but Steam appdetails returned success:false for it.
# Confirm it (SteamDB or the game's docs) before setting it. Until then, start.sh refuses to run.
server_app_id=""
install_dir=/config/serverfiles
steamcmd_dir=/config/Steam/steamcmd

if [ -z "${server_app_id}" ]; then
    echo "Error: the dedicated server Steam app ID is not set in start.sh yet. See the PR blockers." >&2
    exit 1
fi

# Seed SteamCMD into /config on first run, the same way the steamcmd base image does.
mkdir -p "${steamcmd_dir}/linux32" "${install_dir}"
if [ ! -f "${steamcmd_dir}/steamcmd.sh" ]; then
    cp /usr/local/share/steamcmd/steamcmd.sh "${steamcmd_dir}/"
    cp /usr/local/share/steamcmd/linux32/steamcmd "${steamcmd_dir}/linux32/"
fi

# Install or update the server. Running on every start is idempotent. Writes go only to /config and /tmp.
cd "${steamcmd_dir}"
if ! "${steamcmd_dir}/steamcmd.sh" +force_install_dir "${install_dir}" +login anonymous +app_update "${server_app_id}" validate +quit; then
    echo "Error: SteamCMD failed to install app ${server_app_id} into ${install_dir}." >&2
    exit 1
fi

# UNVERIFIED: the server binary path, its launch arguments and the bind option. Confirm from the installed tree.
# Once confirmed, `exec` the server so signals reach it as PID 1.
echo "Error: the server launch command is not verified yet. Installed files are in ${install_dir}." >&2
exit 1
