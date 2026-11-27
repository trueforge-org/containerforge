#!/usr/bin/env bash
set -euo pipefail

# Slash stores its SQLite data in /var/opt/slash, a build-time symlink to /config/slash.
# Its data-dir check fails when the directory is missing, so create it on first start.
mkdir -p /config/slash

export SLASH_MODE="${SLASH_MODE:-prod}"
export SLASH_PORT="${SLASH_PORT:-5231}"

cd /config
echo "Starting Slash on port ${SLASH_PORT}"
# UNVERIFIED: confirm the env names and listen address (0.0.0.0) in bin/slash/main.go
exec /app/slash/slash
