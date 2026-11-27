#!/usr/bin/env bash

# All configuration is read by the app from the environment (see settings.yaml).
# The app exits with its own error when a required variable is missing; report it here too.
missing=""
for v in AMCREST_HOST AMCREST_PASSWORD MQTT_USERNAME; do
  if [ -z "${!v:-}" ]; then
    missing="${missing} ${v}"
  fi
done
if [ -n "${missing}" ]; then
  echo "[amcrest2mqtt] ERROR: required environment variable(s) not set:${missing}" >&2
fi

cd /app/amcrest2mqtt/src
exec /app/venv/bin/python -u /app/amcrest2mqtt/src/amcrest2mqtt.py
