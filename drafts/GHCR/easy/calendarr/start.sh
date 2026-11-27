#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config/custom_footers /config/logs

# Seed the footer templates only when missing or empty; never overwrite user files.
for f in discord_footer.md slack_footer.md; do
  if [[ ! -s /config/custom_footers/$f && -f /defaults/custom_footers/$f ]]; then
    cp "/defaults/custom_footers/$f" "/config/custom_footers/$f"
  fi
done

cd /app
exec /app/venv/bin/python -m calendarr
