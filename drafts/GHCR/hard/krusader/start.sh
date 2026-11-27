#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export DISPLAY=:99

CUSTOM_RES_W="${CUSTOM_RES_W:-1280}"
CUSTOM_RES_H="${CUSTOM_RES_H:-768}"
CUSTOM_DEPTH="${CUSTOM_DEPTH:-16}"

# Session state goes to /config. Sockets and scratch go to /tmp.
mkdir -p /config/krusader /config/.fluxbox /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix 2>/dev/null || true
cd /config/krusader

PIDS=()

Xvfb "${DISPLAY}" -nolisten tcp -screen 0 "${CUSTOM_RES_W}x${CUSTOM_RES_H}x${CUSTOM_DEPTH}" &
PIDS+=($!)

# Wait for the X socket before starting clients that need the display.
for _ in $(seq 1 50); do
    [[ -S /tmp/.X11-unix/X99 ]] && break
    sleep 0.2
done

fluxbox &
PIDS+=($!)

# VNC listens on loopback only, so only websockify reaches it.
# UNVERIFIED decision: -nopw leaves noVNC on port 8080 without authentication. Add auth before the PR.
x11vnc -display "${DISPLAY}" -forever -shared -nopw -localhost -rfbport 5900 -quiet &
PIDS+=($!)

krusader &
PIDS+=($!)

trap 'kill -TERM "${PIDS[@]}" 2>/dev/null || true' TERM INT

# websockify is the last long-running process. It serves noVNC on 8080 and proxies to VNC on 5900.
websockify --web=/usr/share/novnc 8080 localhost:5900 &
PIDS+=($!)
wait -n "${PIDS[@]}" || true
kill -TERM "${PIDS[@]}" 2>/dev/null || true
wait
