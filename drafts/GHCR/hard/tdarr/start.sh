#!/usr/bin/env bash
set -euo pipefail

# /app/configs, /app/logs and /app/server are symlinks to /config (set in the Dockerfile).
# Transcode scratch is ephemeral and lives in /tmp. UNVERIFIED: the knob that points Tdarr at /tmp/transcode.
mkdir -p /config/configs /config/logs /config/server /tmp/home /tmp/transcode
umask "${UMASK:-002}"

# UNVERIFIED: the env names the binaries read. The compose example uses these lowercase names.
export webUIPort="${WEB_UI_PORT:-8265}"
export serverPort="${SERVER_PORT:-8266}"
export inContainer=true
export nodeName="${nodeName:-InternalNode}"
INTERNAL_NODE="${internalNode:-true}"

cd /app/Tdarr_Server
./Tdarr_Server &

if [ "${INTERNAL_NODE}" = "true" ]; then
  export serverIP=127.0.0.1
  (cd /app/Tdarr_Node && exec ./Tdarr_Node) &
fi

# Process model: documented exception. Server and node run side by side, so a supervisor waits for either to exit.
trap 'kill -TERM $(jobs -p) 2>/dev/null || true' TERM INT
wait -n || true
kill -TERM $(jobs -p) 2>/dev/null || true
wait || true
