#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/downloads /config/state /tmp/metube /tmp/cache

# bgutil-pot is the YouTube PO-token provider that yt-dlp talks to.
/usr/local/bin/bgutil-pot server >/tmp/bgutil-pot.log 2>&1 &

cd /app
exec /app/venv/bin/python app/main.py
