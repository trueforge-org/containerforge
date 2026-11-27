#!/usr/bin/env bash
set -euo pipefail

# The bot session (bot.session) is written to the working directory, so run from /config.
cd /config

# The app reads these itself, and it applies its own defaults (PATH_CONFIG=/config/,
# DOWNLOAD_PATH_TORRENTS=/watch, TG_DOWNLOAD_PATH=/download). They are not exported here,
# because an export would hide the DOWNLOAD_PATH alias.

# Each credential accepts either name, as the app does. Values are never printed.
missing=()
[ -n "${API_ID:-${TG_API_ID:-}}" ] || missing+=("TG_API_ID")
[ -n "${API_HASH:-${TG_API_HASH:-}}" ] || missing+=("TG_API_HASH")
[ -n "${BOT_TOKEN:-${TG_BOT_TOKEN:-}}" ] || missing+=("TG_BOT_TOKEN")
[ -n "${AUTHORIZED_USER_ID:-${TG_AUTHORIZED_USER_ID:-}}" ] || missing+=("TG_AUTHORIZED_USER_ID")

mkdir -p /config /download /watch 2>/dev/null || true

if [ "${#missing[@]}" -gt 0 ]; then
    # UNVERIFIED design choice: upstream exits 1 here. Idling keeps the container up
    # without a crash loop, so it can start without env vars.
    echo "Telegram credentials missing: set ${missing[*]}, then restart the container."
    exec sleep infinity
fi

exec /app/venv/bin/python /app/telethon/app.py
