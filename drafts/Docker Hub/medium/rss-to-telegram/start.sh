#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${TOKEN:-}" || -z "${CHATID:-}" ]]; then
    echo "ERROR: TOKEN and CHATID must be set" >&2
    exit 1
fi

mkdir -p /config
cd /app
# start_bot.sh runs the prisma migrations, then starts node (it does not exec node itself: UNVERIFIED, may need a fix)
exec ./start_bot.sh
