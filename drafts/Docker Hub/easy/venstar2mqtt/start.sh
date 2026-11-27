#!/usr/bin/env bash
# Writes nothing to disk. Secrets (MQTT_PASS) stay in the environment only.

export TOPIC_PREFIX="${TOPIC_PREFIX:-/venstar}"
export LOGGING_NAME="${LOGGING_NAME:-venstar2mqtt}"

# The app calls process.abort() when MQTT_HOST or VENSTAR_HOST is missing.
# Idle with a clear message instead, so the container stays up until it is configured.
if [ -z "${MQTT_HOST:-}" ] || [ -z "${VENSTAR_HOST:-}" ]; then
  echo "venstar2mqtt: MQTT_HOST and VENSTAR_HOST must be set; idling until configured" >&2
  exec sleep infinity
fi

cd /app/venstar2mqtt
exec node index.js
