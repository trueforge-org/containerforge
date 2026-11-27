#!/usr/bin/env bash
set -euo pipefail

echo "[10-shlink] Preparing nginx site and servers.json"
mkdir -p /config/sites
cp /defaults/default.conf /config/sites/default.conf

# Escape a value for a JSON string (backslash and double quote).
json_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '%s' "$s"
}

if [ -n "${SHLINK_SERVER_URL:-}" ] && [ -n "${SHLINK_SERVER_API_KEY:-}" ]; then
  umask 077
  printf '[{"name":"%s","url":"%s","apiKey":"%s"}]\n' \
    "$(json_escape "${SHLINK_SERVER_NAME:-Shlink}")" \
    "$(json_escape "${SHLINK_SERVER_URL}")" \
    "$(json_escape "${SHLINK_SERVER_API_KEY}")" > /config/servers.json.tmp
  mv /config/servers.json.tmp /config/servers.json
elif [ ! -s /config/servers.json ]; then
  echo '[]' > /config/servers.json
fi
