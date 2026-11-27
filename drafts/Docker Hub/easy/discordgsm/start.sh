#!/usr/bin/env bash
set -euo pipefail

# /app/data is a symlink to /config/data (sqlite DB and logs).
mkdir -p /config/data/logs

# The bot cannot run without a Discord token. Idle instead of exiting so the image starts without env vars.
# The token is checked for its 3 dot-separated parts, as upstream main.py does, and never printed.
if [ "$(printf '%s' "${APP_TOKEN:-}" | awk -F. '{print NF}')" != "3" ]; then
  echo "APP_TOKEN is missing or malformed (expected a Discord bot token). See https://discordgsm.com/guide/how-to-get-a-discord-bot-token . Idling." >&2
  exec sleep infinity
fi

cd /app
exec /app/venv/bin/python -u /app/main.py
