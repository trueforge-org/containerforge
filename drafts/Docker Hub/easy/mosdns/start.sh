#!/usr/bin/env bash
set -euo pipefail

MOSDNS_PORT="${MOSDNS_PORT:-5353}"
MOSDNS_UPSTREAM="${MOSDNS_UPSTREAM:-https://8.8.8.8/dns-query}"

# seed the config only when missing or empty, so user rules are never overwritten
if [[ ! -s /config/config.yaml ]]; then
  [[ "${MOSDNS_PORT}" =~ ^[0-9]+$ ]] || { echo "MOSDNS_PORT must be numeric" >&2; exit 1; }
  [[ "${MOSDNS_UPSTREAM}" =~ ^[A-Za-z0-9:/._?=-]+$ ]] || { echo "MOSDNS_UPSTREAM contains unsupported characters" >&2; exit 1; }
  export MOSDNS_PORT MOSDNS_UPSTREAM
  envsubst '${MOSDNS_PORT} ${MOSDNS_UPSTREAM}' < /defaults/config.yaml > /config/config.yaml
fi

cd /config
exec /app/mosdns start -c /config/config.yaml -d /config
