#!/usr/bin/env bash

# seed the configuration only when it is missing, so user state is kept
if [[ ! -s /config/configuration.yaml ]]; then
  cp /defaults/configuration.example.yaml /config/configuration.yaml
fi

export ZIGBEE2MQTT_DATA=/config

cd /app || exit 1
# UNVERIFIED: frontend host default and log directory are not confirmed; check on the first run
exec node /app/index.js
