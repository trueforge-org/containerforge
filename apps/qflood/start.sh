#!/usr/bin/env bash

CONFIG_FILE="/config/qBittorrent/qBittorrent.conf"
LOG_FILE="/config/qBittorrent/logs/qbittorrent.log"
QBT_PORT="${QBT_WEBUI_PORT:-8080}"

# Ensure the qBittorrent config exists, copy default if missing
if [[ ! -f "${CONFIG_FILE}" ]]; then
    mkdir -p "${CONFIG_FILE%/*}"
    cp /defaults/qBittorrent.conf "${CONFIG_FILE}"
fi

# Redirect the qBittorrent log file to stdout
if [[ ! -f "${LOG_FILE}" ]]; then
    mkdir -p "${LOG_FILE%/*}"
    ln -sf /proc/self/fd/1 "${LOG_FILE}"
fi

mkdir -p /config/flood

# Flood talks to qBittorrent on localhost. With FLOOD_AUTH=none Flood logs in for every visitor,
# otherwise Flood asks for the qBittorrent connection details on first visit.
FLOOD_ARGS=(
    --rundir /config/flood
    --host 0.0.0.0
    --port 3000
    --allowedpath /data
    --allowedpath /config
)
if [[ "${FLOOD_AUTH:-}" == "none" ]]; then
    FLOOD_ARGS+=(
        --auth none
        --qburl "http://127.0.0.1:${QBT_PORT}"
        --qbuser "${QBT_USER:-}"
        --qbpass "${QBT_PASS:-}"
    )
fi

/app/qbittorrent-nox --webui-port="${QBT_PORT}" &
QBT_PID=$!
/app/flood "${FLOOD_ARGS[@]}" &
FLOOD_PID=$!

# Forward termination signals to both processes
trap 'kill -TERM "${QBT_PID}" "${FLOOD_PID}" 2>/dev/null' TERM INT

# Exit as soon as one of the two stops, so the container gets restarted
wait -n "${QBT_PID}" "${FLOOD_PID}"
STATUS=$?
kill -TERM "${QBT_PID}" "${FLOOD_PID}" 2>/dev/null
wait
exit "${STATUS}"
