#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export XDG_RUNTIME_DIR=/tmp/runtime
export DISPLAY=:1

mkdir -p /config "${XDG_CACHE_HOME}" "${XDG_RUNTIME_DIR}"
chmod 0700 "${XDG_RUNTIME_DIR}"

Xvfb "${DISPLAY}" -screen 0 1280x768x24 -nolisten tcp &
# UNVERIFIED: fixed wait for the X server, replace with a readiness check once tested
sleep 2

if [ -n "${VNC_PASSWORD:-}" ]; then
  x11vnc -storepasswd "${VNC_PASSWORD}" /tmp/vnc.passwd >/dev/null
  vnc_auth=(-rfbauth /tmp/vnc.passwd)
else
  echo "mediainfo: VNC_PASSWORD is not set, the VNC server accepts connections without a password" >&2
  vnc_auth=(-nopw)
fi

x11vnc -display "${DISPLAY}" -forever -shared -quiet \
  -listen 0.0.0.0 -rfbport 5900 "${vnc_auth[@]}" &

# UNVERIFIED: GUI binary path, kept as the long-running process so signals reach it
exec /opt/mediainfo/bin/mediainfo-gui "$@"
