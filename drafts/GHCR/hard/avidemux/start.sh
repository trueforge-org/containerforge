#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CONFIG_HOME=/config/xdg/config
export XDG_DATA_HOME=/config/xdg/data
export XDG_CACHE_HOME=/tmp/xdg/cache
export DISPLAY=:1

# Persistent state under /config, scratch under /tmp (read-only rootfs safe).
mkdir -p /config/xdg/config /config/xdg/data /tmp/xdg/cache

# Virtual X display. Xvfb creates its socket in /tmp/.X11-unix.
Xvfb "${DISPLAY}" -screen 0 1280x768x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
for _ in $(seq 1 50); do
  [ -S "/tmp/.X11-unix/X1" ] && break
  sleep 0.2
done

# VNC server on 5900, listening on all interfaces so other containers can reach it.
VNC_ARGS=(-display "${DISPLAY}" -forever -shared -rfbport 5900 -listen 0.0.0.0 -xkb -noxdamage)
if [ -n "${VNC_PASSWORD:-}" ]; then
  # UNVERIFIED: x11vnc -storepasswd takes the password as an argument (briefly visible in the process list).
  x11vnc -storepasswd "${VNC_PASSWORD}" /tmp/vncpasswd >/dev/null 2>&1
  VNC_ARGS+=(-rfbauth /tmp/vncpasswd)
else
  VNC_ARGS+=(-nopw)
fi
x11vnc "${VNC_ARGS[@]}" >/tmp/x11vnc.log 2>&1 &

# noVNC web client on 5800, proxied to the VNC server.
websockify --web /usr/share/novnc 0.0.0.0:5800 localhost:5900 >/tmp/websockify.log 2>&1 &

# Final long-running process. Video files are opened from /storage (user mount).
exec avidemux3_qt5 "$@"
