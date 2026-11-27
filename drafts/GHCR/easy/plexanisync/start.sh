#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

if [ -s /config/settings.ini ]; then
  # A user-provided settings file is used as is and never overwritten.
  export SETTINGS_FILE=/config/settings.ini
else
  # Generated from the environment on every start into ephemeral /tmp with mode
  # 0600, so tokens are not persisted in /config.
  umask 077
  mkdir -p /tmp/plexanisync
  export SETTINGS_FILE=/tmp/plexanisync/settings.ini
  rm -f "${SETTINGS_FILE}"
  /app/venv/bin/python -I - "${SETTINGS_FILE}" <<'PY'
import configparser
import os
import sys

cfg = configparser.ConfigParser()
cfg["PLEX"] = {
    "anime_section": os.environ.get("PLEX_SECTION", "Anime"),
    "authentication_method": "direct",
    "base_url": os.environ.get("PLEX_URL", "http://127.0.0.1:32400"),
    "token": os.environ.get("PLEX_TOKEN", ""),
}
cfg["ANILIST"] = {
    "username": os.environ.get("ANI_USERNAME", ""),
    "access_token": os.environ.get("ANI_TOKEN", ""),
}
with open(sys.argv[1], "w", encoding="utf-8") as fh:
    cfg.write(fh)
PY
fi

# Mirrors the upstream runsync.sh loop. A failed sync is logged and retried on
# the next interval. INTERVAL <= 0 runs one sync and exits.
while true; do
  /app/venv/bin/python /app/plexanisync/PlexAniSync.py || echo "[plexanisync] sync failed"
  if [ "${INTERVAL:-3600}" -le 0 ]; then
    echo "[plexanisync] INTERVAL <= 0, quitting after one sync"
    break
  fi
  sleep "${INTERVAL:-3600}"
done
