#!/bin/bash
set -euo pipefail

VALKEY_PASSWORD="${VALKEY_PASSWORD:-${REDIS_PASSWORD:-}}"
VALKEY_PORT="${VALKEY_PORT:-${REDIS_PORT:-6379}}"

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

args=(
  --bind 0.0.0.0
  --port "$VALKEY_PORT"
)

if [[ -n "$VALKEY_PASSWORD" ]]; then
  args+=(--requirepass "$VALKEY_PASSWORD")
fi

exec valkey-server "${args[@]}" "$@"
