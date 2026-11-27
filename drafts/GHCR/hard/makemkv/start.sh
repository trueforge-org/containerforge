#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CACHE_HOME=/tmp/xdg/cache
export DISPLAY=:1

# MakeMKV keeps its settings in ~/.MakeMKV, so HOME=/config makes them persistent.
mkdir -p /config/.MakeMKV /tmp/xdg/cache

# UNVERIFIED: upstream sets MAKEMKV_KEY=BETA and other MAKEMKV_*/AUTO_DISC_RIPPER_* variables.
# They are not listed in settings.yaml until the binary or a script is confirmed to read them.

# Virtual X display. Xvfb creates its socket in /tmp/.X11-unix.
Xvfb "${DISPLAY}" -screen 0 1280x768x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
for _ in $(seq 1 50); do
  [ -S "/tmp/.X11-unix/X1" ] && break
  sleep 0.2
done

# VNC on 5900 and noVNC on 5800, both on all interfaces.
VNC_ARGS=(-display "${DISPLAY}" -forever -shared -rfbport 5900 -listen 0.0.0.0 -xkb -noxdamage -nopw)
x11vnc "${VNC_ARGS[@]}" >/tmp/x11vnc.log 2>&1 &
websockify --web /usr/share/novnc 0.0.0.0:5800 localhost:5900 >/tmp/websockify.log 2>&1 &

# UNVERIFIED: binary path and GUI launch arguments (upstream jlesage launch scripts were not read).
# Final long-running process.
exec /opt/makemkv/bin/makemkv "$@"
