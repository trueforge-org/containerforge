#!/usr/bin/env bash
# Initial draft. UNVERIFIED: the relay flag (-r) and the ENCRYPTED_ONLY mapping (plan section 7).

set -euo pipefail

mkdir -p /config
cd /config

relay_opts=()
if [ -n "${RELAY:-}" ]; then
  relay_opts=(-r "${RELAY}")
fi

# hbbr runs in the background with no supervisor (plan section 10). If it dies, only hbbs keeps running.
/app/rustdesk/hbbr &

# The key pair is generated into /config on first start and never overwritten.
exec /app/rustdesk/hbbs "${relay_opts[@]}"
