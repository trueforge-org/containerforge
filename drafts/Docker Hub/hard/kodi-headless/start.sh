#!/usr/bin/env bash
set -euo pipefail

KODI_USERDATA=/config/.kodi/userdata
DEFAULTS=/defaults/userdata

echo "[kodi-headless] preparing runtime directories"
mkdir -p "${KODI_USERDATA}" /tmp/runtime /tmp/cache
chmod 700 /tmp/runtime
mkdir -p -m 1777 /tmp/.X11-unix

# Seed config only when missing, never overwrite user state
for f in guisettings.xml advancedsettings.xml; do
  if [ ! -f "${KODI_USERDATA}/${f}" ]; then
    echo "[kodi-headless] seeding ${f}"
    cp "${DEFAULTS}/${f}" "${KODI_USERDATA}/${f}"
  fi
done

# Stock Kodi needs a display: run it on a virtual X server
# UNVERIFIED: Xvfb as a non-root user, and whether kodi --standalone runs headless on Kodi 21
rm -f /tmp/.X99-lock
Xvfb :99 -screen 0 1280x720x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &

for _ in $(seq 1 30); do
  [ -S /tmp/.X11-unix/X99 ] && break
  sleep 1
done

echo "[kodi-headless] starting Kodi"
exec kodi --standalone
