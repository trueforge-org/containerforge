#!/bin/bash
[[ -n "$REDIS_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_PASSWORD"
response=$(
  timeout -s 3 "$1" \
  valkey-cli \
    -h localhost \
    -p "$REDIS_PORT" \
    ping
)
if [ "$response" != "PONG" ] && [ "$response" != "LOADING Valkey is loading the dataset in memory" ]; then
  echo "$response"
  exit 1
fi
