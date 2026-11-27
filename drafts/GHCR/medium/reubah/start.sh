#!/usr/bin/env bash
set -eu

# Scratch, LibreOffice profile and caches go to /tmp (HOME=/tmp). Nothing is written to /app.
mkdir -p /tmp/.cache /tmp/.config /tmp/.local

cd /app
export PORT="${PORT:-8081}"

# UNVERIFIED: the server must bind all interfaces (check cmd/server in the build stage)
exec /app/reubah
