#!/usr/bin/env bash
set -euo pipefail

cd /config
mkdir -p app/config

# An empty "token" env var overrides bot.env in confighelper.py, so drop it when empty.
if [ -z "${token:-}" ]; then
  unset token
  if ! grep -Eq '^discord_bot_token=.+' bot.env 2>/dev/null; then
    echo 'No Discord token set (env "token" or /config/bot.env); idling.'
    exec sleep infinity
  fi
fi

exec /app/venv/bin/python -u /app/invitarr/run.py
