#!/usr/bin/env bash
set -euo pipefail

VNC_PORT="${VNC_PORT:-5901}"
NOVNC_PORT="${NOVNC_PORT:-6901}"
VNC_RESOLUTION="${VNC_RESOLUTION:-1360x768}"
VNC_COL_DEPTH="${VNC_COL_DEPTH:-24}"
export HOME=/config XDG_CONFIG_HOME=/config/.config XDG_CACHE_HOME=/tmp/.cache XDG_RUNTIME_DIR=/tmp/runtime DISPLAY=:1

mkdir -p /config/.vnc /config/.config /tmp/runtime /tmp/.cache /tmp/.X11-unix
chmod 700 /tmp/runtime
chmod 1777 /tmp/.X11-unix

# Seed the session script only when missing.
if [ ! -f /config/.vnc/xstartup ]; then
  cp /defaults/xstartup /config/.vnc/xstartup
fi
chmod 755 /config/.vnc/xstartup

# VNC password: use VNC_PW when set, otherwise generate one and log it for this start.
# The password is passed on stdin to vncpasswd, never on the command line.
if [ -n "${VNC_PW:-}" ]; then
  vnc_pw="${VNC_PW}"
else
  vnc_pw="$(openssl rand -base64 12)"
  echo "VNC_PW not set, generated password for this start: ${vnc_pw}"
fi
printf '%s' "${vnc_pw}" | vncpasswd -f > /config/.vnc/passwd
chmod 600 /config/.vnc/passwd

# Clear a stale lock from a previous unclean stop.
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# UNVERIFIED: option names for TigerVNC 1.15 (check `Xtigervnc -help`). Listens on all interfaces so other containers can connect.
Xtigervnc :1 \
  -rfbport "${VNC_PORT}" \
  -rfbauth /config/.vnc/passwd \
  -SecurityTypes VncAuth \
  -localhost off \
  -geometry "${VNC_RESOLUTION}" \
  -depth "${VNC_COL_DEPTH}" &

for _ in $(seq 1 30); do
  [ -S /tmp/.X11-unix/X1 ] && break
  sleep 1
done

# Desktop session with Inkscape available from the menu.
/config/.vnc/xstartup &

# websockify serves noVNC in the foreground and proxies it to the VNC port.
# UNVERIFIED: /usr/share/novnc path and vnc.html entry file for novnc 1:1.6.0.
exec websockify --web /usr/share/novnc "0.0.0.0:${NOVNC_PORT}" "localhost:${VNC_PORT}"
