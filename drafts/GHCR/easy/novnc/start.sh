#!/usr/bin/env bash
set -euo pipefail

# websockify serves the noVNC web client from /app/novnc and proxies WebSocket traffic to the VNC server.
# UNVERIFIED on 0.13.0: confirm the listen address (expected all interfaces) in the startup log.
exec /app/venv/bin/websockify \
    --web /app/novnc \
    6080 \
    "${REMOTE_HOST:-localhost}:${REMOTE_PORT:-5900}"
