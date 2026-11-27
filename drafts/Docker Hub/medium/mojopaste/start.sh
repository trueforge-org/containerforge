#!/usr/bin/env bash
set -euo pipefail

# Paste data lives in /config/data. Create it only when missing, and never seed or overwrite it.
PASTE_DIR="${PASTE_DIR:-/config/data}"
mkdir -p "$PASTE_DIR"
export PASTE_DIR

cd /app/mojopaste
export MOJO_MODE="${MOJO_MODE:-production}"
# Bind all interfaces so other containers can reach the server. The port matches EXPOSE.
exec /usr/bin/perl ./script/mojopaste prefork -l "http://*:8080"
