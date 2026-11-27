#!/usr/bin/env bash
set -euo pipefail

# The binary reads its settings from the environment (namsral/flag). Fail fast when required values are missing.
: "${RECORD_TYPE:=A}"
export RECORD_TYPE

for var in ZONE_NAME API_TOKEN; do
  if [[ -z "${!var:-}" ]]; then
    echo "hetzner-ddns: ${var} is required" >&2
    exit 1
  fi
done

# Stateless: nothing is written to /app or /config. The token stays in the environment, not on the command line.
exec /app/hetzner-ddns
