#!/usr/bin/env bash
set -euo pipefail

export TRAKTARR_CONFIG="${TRAKTARR_CONFIG:-/config/config.json}"
export TRAKTARR_CACHEFILE="${TRAKTARR_CACHEFILE:-/config/cache.db}"
export TRAKTARR_LOGFILE="${TRAKTARR_LOGFILE:-/config/traktarr.log}"

cd /app/traktarr

if [[ ! -f "${TRAKTARR_CONFIG}" ]]; then
  # The app writes a default config.json and exits. A failing run stops the script (set -e).
  /app/venv/bin/python traktarr.py run
  if [[ ! -f "${TRAKTARR_CONFIG}" ]]; then
    echo "No config written to ${TRAKTARR_CONFIG}" >&2
    exit 1
  fi
  echo "Default config written to ${TRAKTARR_CONFIG}. Add the Trakt, Sonarr and Radarr settings, then restart."
  # Keep the container up on first start so the config can be edited.
  # UNVERIFIED: whether to sleep here or exit and let the orchestrator restart. Decide before PR.
  exec sleep infinity
fi

# Upgrades that add config options make the app save them and exit 0, so one restart is needed then.
exec /app/venv/bin/python traktarr.py run
