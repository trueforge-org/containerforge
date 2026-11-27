#!/usr/bin/env bash

args=()
if [ -f /config/settings.conf ]; then
  # HC_* env overrides the file, so export no defaults here or they would silently mask the user's settings
  args+=(/config/settings.conf)
else
  # Editor target: the Home Assistant config directory (mount it at /hass-config)
  export HC_BASEPATH="${HC_BASEPATH:-/hass-config}"
  export HC_ENFORCE_BASEPATH="${HC_ENFORCE_BASEPATH:-true}"
  export HC_LISTENIP="${HC_LISTENIP:-0.0.0.0}"
  export HC_PORT="${HC_PORT:-3218}"
  # Standalone mode unless a Home Assistant API URL is given (the default 127.0.0.1:8123 is the wrong container)
  export HC_HASS_API="${HC_HASS_API:-None}"
fi

if [ -z "${HC_USERNAME:-}" ] || [ -z "${HC_PASSWORD:-}" ]; then
  echo "WARNING: HC_USERNAME/HC_PASSWORD are not set. Unless the settings file sets credentials, anyone who can reach the editor (port ${HC_PORT:-3218}) can edit files." >&2
fi

cd /config
exec /app/venv/bin/hass-configurator "${args[@]}"
