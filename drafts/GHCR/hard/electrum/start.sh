#!/bin/sh
set -eu

# Wallet data is persistent and lives only under /config. Caches and sockets live in /tmp.
DATA_DIR="${DATA_DIR:-/config/electrum}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
CUSTOM_RES_W="${CUSTOM_RES_W:-1024}"
CUSTOM_RES_H="${CUSTOM_RES_H:-768}"
CUSTOM_DEPTH="${CUSTOM_DEPTH:-16}"
export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache

mkdir -p "${DATA_DIR}" "${XDG_CACHE_HOME}" /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Virtual display. Electrum is a Qt GUI and needs an X server.
Xvfb "${DISPLAY}" -screen 0 "${CUSTOM_RES_W}x${CUSTOM_RES_H}x${CUSTOM_DEPTH}" -nolisten tcp &

# UNVERIFIED: no readiness wait for Xvfb. Add one if the window manager or Electrum fails to connect on first start.
fluxbox >/dev/null 2>&1 &

# VNC is bound to localhost only and has no password. Access is only through noVNC on this container.
# UNVERIFIED: whether a password is required instead (open decision in the PR).
x11vnc -display "${DISPLAY}" -localhost -nopw -forever -shared -rfbport 5900 -quiet &

/app/venv/bin/electrum --dir "${DATA_DIR}" >/dev/null 2>&1 &

# exec the noVNC bridge so signals reach the container's main process.
exec websockify --web /usr/share/novnc/ "0.0.0.0:${NOVNC_PORT}" localhost:5900
