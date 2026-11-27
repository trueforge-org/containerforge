#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Seed the settings once. Never overwrite existing user state.
if [ ! -f /config/settings.json ]; then
  cp /defaults/settings.json /config/settings.json
fi

cd /app
# FB_PORT and FB_ADDRESS are read by filebrowser itself (viper FB_ prefix).
exec /app/filebrowser --config /config/settings.json "$@"
