#!/bin/bash
VALKEY_MASTER_PASSWORD="${VALKEY_MASTER_PASSWORD:-${REDIS_MASTER_PASSWORD:-}}"
VALKEY_MASTER_HOST="${VALKEY_MASTER_HOST:-${REDIS_MASTER_HOST:-}}"
VALKEY_MASTER_PORT_NUMBER="${VALKEY_MASTER_PORT_NUMBER:-${REDIS_MASTER_PORT_NUMBER:-6379}}"
[[ -n "$VALKEY_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$VALKEY_MASTER_PASSWORD"
response=$(
  timeout -s 3 "$1" \
  valkey-cli \
    -h "$VALKEY_MASTER_HOST" \
    -p "$VALKEY_MASTER_PORT_NUMBER" \
    ping
)
if [ "$response" != "PONG" ] && [ "$response" != "LOADING Valkey is loading the dataset in memory" ]; then
  echo "$response"
  exit 1
fi
