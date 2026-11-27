#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_RUNTIME_DIR=/tmp
export LANG="${THUNDERBIRD_LANG:-en-US}.UTF-8"

CUSTOM_RES_W="${CUSTOM_RES_W:-1024}"
CUSTOM_RES_H="${CUSTOM_RES_H:-768}"
CUSTOM_DEPTH="${CUSTOM_DEPTH:-16}"
PROFILE_DIR=/config/thunderbird

mkdir -p "${PROFILE_DIR}"

# virtual display for Thunderbird
Xvfb :99 -screen 0 "${CUSTOM_RES_W}x${CUSTOM_RES_H}x${CUSTOM_DEPTH}" >/tmp/xvfb.log 2>&1 &
export DISPLAY=:99

# VNC on localhost only, noVNC web UI on all interfaces
x11vnc -display :99 -forever -shared -nopw -rfbport 5900 -localhost >/tmp/x11vnc.log 2>&1 &
websockify --web /usr/share/novnc 0.0.0.0:8080 localhost:5900 >/tmp/websockify.log 2>&1 &

# keep Thunderbird in the persistent profile; exec so it is not wrapped
exec /app/thunderbird/thunderbird --no-remote --profile "${PROFILE_DIR}"
