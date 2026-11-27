#!/usr/bin/env bash
set -euo pipefail

# The bot cannot start without its Discord token. Fail with a clear message instead of a stack trace.
: "${DISCORD_TOKEN:?DISCORD_TOKEN is required (the Discord bot token)}"

# /app/data is a symlink into /config (made at build time). Create the target only when missing.
mkdir -p /config/data

cd /app
exec yarn start
