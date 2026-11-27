#!/usr/bin/env bash
set -euo pipefail

port="${TUNNEL_DNS_PORT:-5053}"
address="${TUNNEL_DNS_ADDRESS:-0.0.0.0}"
upstreams="${DOH_UPSTREAMS:-https://1.1.1.1/dns-query https://1.0.0.1/dns-query}"

# Pass each upstream as its own flag; UNVERIFIED that a comma or space list works in TUNNEL_DNS_UPSTREAM.
args=()
for u in ${upstreams}; do
  args+=(--upstream "$u")
done

exec /app/cloudflared proxy-dns \
  --address "$address" \
  --port "$port" \
  "${args[@]}"
