#!/usr/bin/env bash
set -euo pipefail

# Refuse to expose an unauthenticated desktop.
if [[ -z "${VNC_PASSWORD:-}" ]]; then
  echo "VNC_PASSWORD is not set; refusing to start an unauthenticated desktop" >&2
  exit 1
fi

export HOME=/config
export XDG_RUNTIME_DIR=/tmp/xdg
export DISPLAY=:1

mkdir -p /config/.vnc /tmp/xdg
chmod 700 /tmp/xdg

# Rewrite the VNC password file on every start so a changed password applies.
# UNVERIFIED: the password is an argument here, so it is briefly visible in the process list.
x11vnc -storepasswd "${VNC_PASSWORD}" /config/.vnc/passwd >/dev/null

Xvfb :1 -screen 0 1280x800x24 &
# UNVERIFIED: replace this fixed sleep with a wait for the X socket.
sleep 2
openbox &
hexchat &
x11vnc -display :1 -forever -shared -rfbauth /config/.vnc/passwd -rfbport 5900 -quiet &

# UNVERIFIED: websockify listens on all interfaces by default; confirm.
# Several long-running processes: PID 1 supervision is an open decision (see the plan).
exec websockify --web=/usr/share/novnc 6080 localhost:5900
