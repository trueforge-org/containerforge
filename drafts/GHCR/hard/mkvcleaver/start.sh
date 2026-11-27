#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Wine and X scratch lives in /tmp. Nothing writes to /opt.
DISPLAY="${DISPLAY:-:0}"
DISPLAY_WIDTH="${DISPLAY_WIDTH:-1920}"
DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-1080}"
WEB_LISTENING_PORT="${WEB_LISTENING_PORT:-5800}"
VNC_LISTENING_PORT="${VNC_LISTENING_PORT:-5900}"
export DISPLAY WINEPREFIX="${WINEPREFIX:-/tmp/wine}"

mkdir -p /config "$WINEPREFIX"

# Optional VNC password, stored obfuscated in /config only when set.
# UNVERIFIED: x11vnc takes the password as an argument, so it is briefly visible in the process list. Not covered by the empty-env test.
RFB_AUTH=()
if [ -n "${VNC_PASSWORD:-}" ]; then
  x11vnc -storepasswd "${VNC_PASSWORD}" /config/.vncpass >/dev/null 2>&1
  RFB_AUTH=(-rfbauth /config/.vncpass)
fi

Xvfb "$DISPLAY" -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24" -nolisten tcp &

# Wait until the X display answers before starting clients.
for _ in $(seq 1 50); do
  xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 && break
  sleep 0.2
done

x11vnc -display "$DISPLAY" -rfbport "$VNC_LISTENING_PORT" -forever -shared -listen 0.0.0.0 "${RFB_AUTH[@]}" &

# Web GUI (noVNC) on all interfaces. UNVERIFIED: /usr/share/novnc is the Debian/Ubuntu path.
websockify --web /usr/share/novnc "$WEB_LISTENING_PORT" "localhost:${VNC_LISTENING_PORT}" &

cd /opt/mkvcleaver
wine /opt/mkvcleaver/MKVCleaver.exe &

# Process model: documented exception. Several GUI services run side by side, so a supervisor waits for any to exit.
trap 'kill -TERM $(jobs -p) 2>/dev/null || true' TERM INT
wait -n || true
kill -TERM $(jobs -p) 2>/dev/null || true
wait || true
