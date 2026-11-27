#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p -m 0700 "${XDG_RUNTIME_DIR}"

# Hardware is optional; the web UI and network LED targets work without it
if ! compgen -G "/dev/ttyUSB*" >/dev/null && \
   ! compgen -G "/dev/spidev*" >/dev/null && \
   ! compgen -G "/dev/video*" >/dev/null; then
  echo "WARNING: no serial, SPI or video devices visible; local LED output and capture are unavailable" >&2
fi

# UNVERIFIED: default bind addresses of the web UI and the JSON/FlatBuffers servers.
# Check from outside the container; if a server binds localhost, change it in the settings JSON.
exec hyperiond --userdata /config -s
