#!/usr/bin/env bash
set -euo pipefail

# Persistent state only. Nothing is written to /app.
mkdir -p /config/obsidian /vaults

export DISPLAY=:99
PORT="${CUSTOM_PORT:-8080}"

# UNVERIFIED: start the X display, the VNC server and the web front end, then Obsidian.
# Background children are not PID 1 safe, so a small supervisor may be needed (see plan section 7).
Xvfb "${DISPLAY}" -screen 0 1280x800x24 -nolisten tcp &
x11vnc -display "${DISPLAY}" -rfbport 5900 -nopw -forever -shared -quiet &
websockify --web /usr/share/novnc "0.0.0.0:${PORT}" localhost:5900 &

# UNVERIFIED: AppRun path inside the extracted AppImage. --no-sandbox is not added until the run step shows it is needed.
exec /app/obsidian/AppRun "$@"
