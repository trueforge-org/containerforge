#!/usr/bin/env bash
set -euo pipefail

cd /config
mkdir -p /config/ical_export

# Seed the sample mapping only when missing. Never overwrite user state.
[ -f /config/calendar_download_map.py ] || cp /defaults/calendar_download_map.py /config/calendar_download_map.py

if [[ -z "${ICS_URL:-}" || -z "${ICS_USERNAME:-}" ]]; then
  echo "import-ics: ICS_URL/ICS_USERNAME not set; jobs will fail until configured"
fi

# Rebuilt on every start in /tmp, so schedule changes apply after a restart.
: "${CRONTAB_SCHEDULE:=0 0 * * *}"
printf '%s /app/venv/bin/python /app/import_ics/import_ics.py\n' "${CRONTAB_SCHEDULE}" > /tmp/crontab

# Credentials stay in the environment and are never written to a file or argv.
exec supercronic /tmp/crontab
