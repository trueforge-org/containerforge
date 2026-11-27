#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

# The binary writes config.json and updates.json into DATADIR on first run, so /config may start empty.
# Listening on :8000 means all interfaces.
exec /app/ddns-updater
