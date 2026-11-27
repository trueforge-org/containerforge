#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export XDG_RUNTIME_DIR=/tmp/runtime
export TZ="${TZ:-Etc/UTC}"
export DISPLAY_SIZEW="${DISPLAY_SIZEW:-1600}"
export DISPLAY_SIZEH="${DISPLAY_SIZEH:-900}"
export DISPLAY_CDEPTH="${DISPLAY_CDEPTH:-24}"
export ENABLE_STEAM="${ENABLE_STEAM:-true}"
export STEAM_ARGS="${STEAM_ARGS--silent}"
export WEBUI_PASS="${WEBUI_PASS:-}"

# Steam state lives in /config (HOME). X, PulseAudio and runtime sockets live in /tmp.
mkdir -p /config/.steam /config/.local/share /config/.config \
  /tmp/.cache /tmp/pulse /tmp/runtime /tmp/.X11-unix
chmod 700 /tmp/runtime
chmod 1777 /tmp/.X11-unix

# Supervisor starts Xvfb, x11vnc, websockify (noVNC on 8083), XFCE, PulseAudio and Steam.
exec /usr/bin/supervisord -n -c /etc/supervisor/steam-headless.conf
