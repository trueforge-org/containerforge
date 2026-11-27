#!/usr/bin/env bash
set -euo pipefail

# Values are never echoed, so secrets stay out of the logs.
if [[ -z "${PRIMARY:-}" && -z "${PRIMARY_FILE:-}" ]]; then
  echo "ERROR: set PRIMARY (url|password) or PRIMARY_FILE" >&2
  exit 1
fi

if [[ -z "${REPLICAS:-}" && -z "${REPLICAS_FILE:-}" ]]; then
  echo "ERROR: set REPLICAS (url|password,...) or REPLICAS_FILE" >&2
  exit 1
fi

export TZ="${TZ:-Etc/UTC}"

cd /app
exec /app/nebula-sync run
