#!/bin/bash
set -euo pipefail

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

# The shipped config.toml points to /data (a symlink to /config): logs in /data/logs and sqlite:/data/pt_helper.db.
mkdir -p /config/logs

# Seed the empty vendor database only when there is none.
if [[ ! -s /config/pt_helper.db ]]; then
  cp /app/pt_helper.db /config/pt_helper.db
fi

# The app finds ./config, ./template and ./public relative to the working directory.
cd /app
exec /app/pt_helper "$@"
