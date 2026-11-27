#!/usr/bin/env bash

mkdir -p /config

# The v0.6 README documents the required env vars. Warn when one is missing, but still start, since the app's exact behaviour is UNVERIFIED.
for var in LEAF_USERNAME LEAF_PASSWORD LEAF_TYPE MQTT_HOST; do
    if [[ -z "${!var:-}" ]]; then
        echo "WARNING: ${var} is not set" >&2
    fi
done

cd /config
# UNVERIFIED: the upstream CMD takes no arguments and the config/state path is not confirmed. Credentials come from env, not the command line.
exec /app/bin/leaf_2_mqtt
