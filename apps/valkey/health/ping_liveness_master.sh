#!/bin/bash
[[ -n "$REDIS_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_MASTER_PASSWORD"
response=$(
  timeout -s 3 "$1" \
  valkey-cli \
    -h "$REDIS_MASTER_HOST" \
    -p "$REDIS_MASTER_PORT_NUMBER" \
    ping
)
if [ "$response" != "PONG" ] && [ "$response" != "LOADING Valkey is loading the dataset in memory" ]; then
  echo "$response"
  exit 1
fi
