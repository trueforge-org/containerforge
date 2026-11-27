#!/usr/bin/env bash
set -euo pipefail

# Defaults match settings.yaml and upstream config.js.
export PORT="${PORT:-7879}"
export NODE_ENV=production

# Nothing is written to /app and no /config seeding is needed.
# exec so node receives signals directly.
cd /app/slack-invite
exec node ./bin/www
