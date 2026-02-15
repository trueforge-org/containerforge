#!/bin/bash
VALKEY_PASSWORD="${VALKEY_PASSWORD:-${REDIS_PASSWORD:-}}"
VALKEY_PORT="${VALKEY_PORT:-${REDIS_PORT:-6379}}"
[[ -n "$VALKEY_PASSWORD" ]] && export REDISCLI_AUTH="$VALKEY_PASSWORD"
response=$(
  timeout -s 3 "$1" \
  valkey-cli \
    -h localhost \
    -p "$VALKEY_PORT" \
    ping
)
if [ "$response" != "PONG" ] && [ "$response" != "LOADING Valkey is loading the dataset in memory" ]; then
  echo "$response"
  exit 1
fi
