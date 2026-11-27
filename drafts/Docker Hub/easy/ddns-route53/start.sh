#!/usr/bin/env bash
set -euo pipefail

# SCHEDULE is needed, or upstream runs once and exits (a restart loop under an orchestrator).
export SCHEDULE="${SCHEDULE:-*/30 * * * *}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

args=()
if [ -f /config/ddns-route53.yml ]; then
  args+=(--config /config/ddns-route53.yml)
elif [ -z "${DDNSR53_ROUTE53_HOSTEDZONEID:-}" ] || [ -z "${DDNSR53_ROUTE53_RECORDSSET_0_NAME:-}" ]; then
  echo "Please set DDNSR53_ROUTE53_HOSTEDZONEID and DDNSR53_ROUTE53_RECORDSSET_0_NAME (plus AWS credentials) or mount /config/ddns-route53.yml. Idling."
  exec sleep infinity
else
  # Env-only mode. Env overrides the config file, so these defaults must not apply to a user's yml.
  export DDNSR53_ROUTE53_RECORDSSET_0_TYPE="${DDNSR53_ROUTE53_RECORDSSET_0_TYPE:-A}"
  export DDNSR53_ROUTE53_RECORDSSET_0_TTL="${DDNSR53_ROUTE53_RECORDSSET_0_TTL:-300}"
fi

exec /app/ddns-route53 "${args[@]}"
