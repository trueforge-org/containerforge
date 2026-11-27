#!/usr/bin/env bash
set -euo pipefail

# Portainer creates its own database in the data dir on first start; nothing is seeded.
export XDG_CACHE_HOME=/tmp/cache
mkdir -p /config /tmp/cache

# UNVERIFIED: flag names are from memory; confirm with `portainer --help` before merge.
exec /app/portainer \
  --data "${PORTAINER_DATA:-/config}" \
  --bind "${PORTAINER_BIND:-:9000}" \
  --bind-https "${PORTAINER_BIND_HTTPS:-:9443}" \
  --tunnel-port "${PORTAINER_TUNNEL_PORT:-8000}" \
  --assets /app/public
