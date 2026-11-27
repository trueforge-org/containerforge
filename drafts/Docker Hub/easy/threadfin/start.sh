#!/usr/bin/env bash
set -euo pipefail

export THREADFIN_PORT="${THREADFIN_PORT:-34400}"
export THREADFIN_BIND_IP_ADDRESS="${THREADFIN_BIND_IP_ADDRESS:-0.0.0.0}"
export THREADFIN_DEBUG="${THREADFIN_DEBUG:-0}"

# Scratch space goes to /tmp, not /config.
export TMPDIR=/tmp

mkdir -p /config

exec /app/threadfin \
  -port="${THREADFIN_PORT}" \
  -bind="${THREADFIN_BIND_IP_ADDRESS}" \
  -config=/config \
  -debug="${THREADFIN_DEBUG}"
