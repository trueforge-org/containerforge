#!/usr/bin/env bash
set -euo pipefail

args=(-display :55 -forever -shared -noxdamage -localhost -rfbport 5900)

if [[ -n "${WEBUI_PASS}" ]]; then
  # UNVERIFIED: x11vnc -storepasswd takes the password as an argument, so it is briefly visible in the process list.
  x11vnc -storepasswd "${WEBUI_PASS}" /tmp/x11vnc.pass >/dev/null
  args+=(-rfbauth /tmp/x11vnc.pass)
else
  args+=(-nopw)
fi

exec x11vnc "${args[@]}"
