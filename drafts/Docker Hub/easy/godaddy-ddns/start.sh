#!/usr/bin/env bash

# Optional JSON settings file. Environment variables override it (upstream behaviour).
if [ -z "${UPDATER_CONFIG_FILE:-}" ] && [ -f /config/config.json ]; then
  export UPDATER_CONFIG_FILE=/config/config.json
fi

# The script raises KeyError when a required value is in neither the environment nor the file.
# Check both, so the container idles with a clear message instead of crash-looping.
missing=""
for key in GODADDY_API_KEY GODADDY_API_SECRET GODADDY_DOMAINS; do
  if [ -z "${!key:-}" ]; then
    if [ -n "${UPDATER_CONFIG_FILE:-}" ] && [ -f "${UPDATER_CONFIG_FILE}" ] \
       && jq -e --arg k "$key" '.[$k] // empty | select(. != "")' "${UPDATER_CONFIG_FILE}" >/dev/null 2>&1; then
      continue
    fi
    missing="${missing} ${key}"
  fi
done

if [ -n "${missing}" ]; then
  echo "godaddy-ddns: missing required setting(s):${missing}. Set them as environment variables or in ${UPDATER_CONFIG_FILE:-/config/config.json}. Idling, no DNS record is changed." >&2
  exec sleep infinity
fi

exec /app/venv/bin/python -u /app/bin/godaddy-publicip-updater.py
