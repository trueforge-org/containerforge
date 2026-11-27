#!/usr/bin/env bash
set -euo pipefail

# CSV output goes to /data, which is a symlink to /config/data (used with WRITE_MISSING_AS_CSV=1).
mkdir -p /config/data

# Upstream exits when Plex is not configured, which would crash-loop or fail the test.
# Idle with a clear message instead.
if [[ -z "${PLEX_URL:-}" || -z "${PLEX_TOKEN:-}" ]]; then
  echo "plex-playlist-sync: PLEX_URL and PLEX_TOKEN are required. Not configured, waiting." >&2
  exec sleep infinity
fi

export APPEND_INSTEAD_OF_SYNC="${APPEND_INSTEAD_OF_SYNC:-0}"

# Run from the writable /config, since spotipy may write a token cache in the working directory.
cd /config
exec /usr/local/bin/python /app/plex-playlist-sync/plex-playlist-sync/run.py
