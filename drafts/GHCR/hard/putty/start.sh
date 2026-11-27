#!/usr/bin/env bash

export HOME=/config
export DISPLAY=:0

# PuTTY saves sessions and keys under $HOME/.putty
mkdir -p /config/.putty

# virtual X display (fixed size for now)
Xvfb "${DISPLAY}" -screen 0 1280x768x24 -nolisten tcp &
# UNVERIFIED: a readiness check on the X socket would be better than a fixed sleep
sleep 2

# VNC on 5900 and noVNC on 5800
# UNVERIFIED: VNC is unauthenticated and bound to 0.0.0.0. Add a password before this image is merged.
x11vnc -display "${DISPLAY}" -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900 -quiet &
websockify --web /usr/share/novnc 5800 localhost:5900 &

# run PuTTY in the foreground so it is the final process
exec putty
