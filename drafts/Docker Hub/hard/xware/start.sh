#!/usr/bin/env bash
set -euo pipefail

# Config and downloads live on the persistent volume. /app stays read-only.
mkdir -p /config/cfg /config/TDDOWNLOAD /tmp/thunder
cd /app/xware

# Stop the children cleanly on SIGTERM/SIGINT (kill the process group).
trap 'trap - TERM INT; kill 0 2>/dev/null; exit 0' TERM INT

# Keep portal running, as the upstream start.sh does. portal starts vod_httpserver and ETMDaemon.
# UNVERIFIED: whether portal daemonizes, so the loop checks by process name and relaunches when both are gone.
while true; do
  if ! pgrep -x portal >/dev/null && ! pgrep -x vod_httpserver >/dev/null; then
    echo "starting portal"
    ./portal &
  fi
  sleep 60 &
  wait $! || true
done
