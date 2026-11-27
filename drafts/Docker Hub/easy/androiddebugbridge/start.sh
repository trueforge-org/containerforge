#!/usr/bin/env bash

# ADB key, pairing records and config live in /config (ANDROID_USER_HOME is set in the Dockerfile).
mkdir -p /config/.android
export ANDROID_USER_HOME=/config/.android

# The upstream script exits 1 when no devices are configured. Without devicelist and without
# /config/config.yml, run only the ADB server on 5037 so the container stays up.
if [[ -z "${devicelist:-}" && ! -f /config/config.yml ]]; then
  echo "[androiddebugbridge] No devicelist env and no /config/config.yml: starting a bare ADB server on 5037 only." >&2
  exec /usr/bin/adb -a -P 5037 server nodaemon
fi

# UNVERIFIED: the script's SIGTERM trap runs only after its current sleep (up to checkfreq seconds).
exec /app/androidtv-connect.sh
