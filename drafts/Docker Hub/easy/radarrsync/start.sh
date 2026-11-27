#!/usr/bin/env bash
set -uo pipefail

DELAY="${DELAY:-900}"
# The script writes ./Output.txt in the working directory.
cd /config

missing=()
for v in RADARR_URL RADARR_KEY RADARR4K_URL RADARR4K_KEY PROFILE_ID; do
  [[ -n "${!v:-}" ]] || missing+=("$v")
done
if (( ${#missing[@]} )); then
  echo "radarrsync: waiting, missing required env: ${missing[*]}"
  exec sleep infinity
fi

# UNVERIFIED: the upstream script calls the Radarr v0.2 /api/movie endpoint. Current Radarr
# serves /api/v3, so each run may fail. Confirm against a live Radarr before relying on it.
trap 'exit 0' TERM INT
while true; do
  /app/venv/bin/python /app/radarrsync/RadarrSync.py || echo "radarrsync: run failed (exit $?)"
  sleep "$DELAY" & wait $!
done
