#!/usr/bin/env bash
set -euo pipefail

# app config lands in /config/.config/Rapid Photo Downloader (persistent)
export HOME=/config
mkdir -p "${HOME}/.config/Rapid Photo Downloader"

# runtime scratch on /tmp, which is a tmpfs under --read-only
export XDG_CACHE_HOME=/tmp/cache
export XDG_RUNTIME_DIR=/tmp/xdg
export DISPLAY=:99
mkdir -p "${XDG_CACHE_HOME}" "${XDG_RUNTIME_DIR}" /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

RES="${RESOLUTION:-1280x800x24}"

# X display, window manager and VNC on localhost only
Xvfb "${DISPLAY}" -screen 0 "${RES}" -nolisten tcp &
if ! timeout 30 bash -c 'until [ -S /tmp/.X11-unix/X99 ]; do sleep 0.2; done'; then
  echo "Xvfb did not start" >&2
  exit 1
fi
fluxbox >/tmp/fluxbox.log 2>&1 &
# no VNC password: x11vnc only listens on localhost and is reached through the noVNC proxy
x11vnc -display "${DISPLAY}" -forever -shared -nopw -rfbport 5900 -localhost -q &

# noVNC on all interfaces so other containers and the browser can reach it
websockify --web=/usr/share/novnc 0.0.0.0:8080 localhost:5900 &

# the app is the last process so signals reach it; the container stops when it exits
exec rapid-photo-downloader
