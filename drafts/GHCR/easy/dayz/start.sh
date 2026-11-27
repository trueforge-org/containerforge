#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

STEAMCMD_DIR=/config/Steam/steamcmd
SERVER_DIR=/config/serverfiles

mkdir -p "${SERVER_DIR}" /tmp/steam

# Seed SteamCMD into /config only when it is missing (same approach as apps/steamcmd/start.sh).
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    mkdir -p "${STEAMCMD_DIR}/linux32"
    cp -L /usr/local/share/steamcmd/steamcmd.sh "${STEAMCMD_DIR}/steamcmd.sh"
fi

# Anonymous login only in this draft. The chart's PASSWRD (Steam login) is not wired up yet.
IFS=',' read -r -a app_ids <<< "${STEAM_APP_IDS:-1042420}"
CMD_ARGS=(+force_install_dir "${SERVER_DIR}" +login anonymous)
for app_id in "${app_ids[@]}"; do
    app_id="${app_id//[[:space:]]/}"
    [ -z "${app_id}" ] && continue
    if ! [[ "${app_id}" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid app id '${app_id}' in STEAM_APP_IDS." >&2
        exit 1
    fi
    if [ "${STEAM_APP_VALIDATE:-false}" = "true" ]; then
        CMD_ARGS+=(+app_update "${app_id}" validate)
    else
        CMD_ARGS+=(+app_update "${app_id}")
    fi
done
CMD_ARGS+=(+quit)

cd "${STEAMCMD_DIR}"
"${STEAMCMD_DIR}/steamcmd.sh" "${CMD_ARGS[@]}"

# UNVERIFIED: the DayZ server binary, its arguments, the serverDZ.cfg path and the bind settings are not confirmed.
# Do not invent them. Fill in from the DayZ hosting documentation once it is fetched.
echo "Error: the DayZ server launch command is not configured yet." >&2
exit 1
