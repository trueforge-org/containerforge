#!/usr/bin/env bash

CONFIG_FILE=/config/config.json

# Seed the default config only when missing or empty. Never overwrite user state.
if [[ ! -s "${CONFIG_FILE}" ]]; then
  cp /defaults/config.json "${CONFIG_FILE}"
fi

if grep -q 'foobar.example' "${CONFIG_FILE}"; then
  echo "WARNING: mqtt.broker_url in ${CONFIG_FILE} is still the placeholder. Set it to your MQTT broker."
fi

cd /app/valetudo-mapper
exec node app.js -f "${CONFIG_FILE}"
