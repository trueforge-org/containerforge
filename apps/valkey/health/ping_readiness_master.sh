#!/bin/bash
[[ -n "$REDIS_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_MASTER_PASSWORD"
response=$(
  timeout -s 3 "$1" \
  valkey-cli \
    -h "$REDIS_MASTER_HOST" \
    -p "$REDIS_MASTER_PORT_NUMBER" \
    ping
)
if [ "$response" != "PONG" ]; then
  echo "$response"
  exit 1
fi
