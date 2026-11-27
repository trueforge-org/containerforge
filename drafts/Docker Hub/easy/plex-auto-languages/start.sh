#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Without PLEX_URL and without a config file the app exits at once, so stay up and say why.
if [[ -z "${PLEX_URL:-}" && ! -f /config/config.yaml ]]; then
  echo "plex-auto-languages: not configured. Set PLEX_URL and PLEX_TOKEN (or PLEX_TOKEN_FILE), or create /config/config.yaml. Waiting."
  exec sleep infinity
fi

exec /usr/local/bin/python /app/plex-auto-languages/main.py -c /config/config.yaml
