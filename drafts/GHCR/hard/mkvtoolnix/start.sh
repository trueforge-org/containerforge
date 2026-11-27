#!/usr/bin/env bash
set -euo pipefail

export HOME="${HOME:-/config}"
export DISPLAY="${DISPLAY:-:0}"
DISPLAY_WIDTH="${DISPLAY_WIDTH:-1920}"
DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-1080}"
VNC_PASSWORD="${VNC_PASSWORD:-}"
WEB_LISTENING_PORT="${WEB_LISTENING_PORT:-5800}"
VNC_LISTENING_PORT="${VNC_LISTENING_PORT:-5900}"

# Persistent state goes to /config. Sockets and scratch go to /tmp.
mkdir -p /config/certs /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix 2>/dev/null || true

PIDS=()

Xvfb "${DISPLAY}" -nolisten tcp -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24" &
PIDS+=($!)

# Wait for the X socket before starting clients.
DISPLAY_NUM="${DISPLAY#:}"
for _ in $(seq 1 50); do
    [[ -S "/tmp/.X11-unix/X${DISPLAY_NUM}" ]] && break
    sleep 0.2
done

AUTH_ARGS=()
if [[ -n "${VNC_PASSWORD}" ]]; then
    # Derived file, rewritten on every start so a changed password applies.
    # UNVERIFIED: x11vnc -storepasswd takes the password as an argument, which shows in the process list. Confirm a stdin form.
    x11vnc -storepasswd "${VNC_PASSWORD}" /config/.vncpass >/dev/null 2>&1
    AUTH_ARGS=(-rfbauth /config/.vncpass)
fi

# UNVERIFIED: VNC listens on all interfaces without a password when VNC_PASSWORD is empty.
x11vnc -display "${DISPLAY}" -rfbport "${VNC_LISTENING_PORT}" -listen 0.0.0.0 -forever -shared -quiet "${AUTH_ARGS[@]}" &
PIDS+=($!)

websockify --web /usr/share/novnc "${WEB_LISTENING_PORT}" "localhost:${VNC_LISTENING_PORT}" &
PIDS+=($!)

mkvtoolnix-gui &
PIDS+=($!)

trap 'kill -TERM "${PIDS[@]}" 2>/dev/null || true' TERM INT

# Stop everything when any one process exits.
wait -n "${PIDS[@]}" || true
kill -TERM "${PIDS[@]}" 2>/dev/null || true
wait
