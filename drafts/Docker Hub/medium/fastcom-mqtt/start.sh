#!/usr/bin/env bash
set -euo pipefail

: "${SLEEP:=3600}" "${MQTT_PORT:=1883}"
: "${MQTT_DOWN:=fastcom/download}" "${MQTT_UP:=fastcom/upload}"
export HOME=/tmp
export PUPPETEER_CACHE_DIR=/app/puppeteer

# Keep the MQTT password out of the process list: pass credentials through an options file in /tmp.
# UNVERIFIED: that the mosquitto_pub shipped in Ubuntu 26.04 accepts -o <file>. If not, fall back to the
# MOSQUITTO_* environment mechanism if it exists, else accept the password on the command line and document it.
opts=/tmp/mosquitto-pub.opts
umask 077
: > "$opts"
[ -n "${MQTT_USER:-}" ] && printf -- '-u %s\n' "$MQTT_USER" >> "$opts"
[ -n "${MQTT_PASS:-}" ] && printf -- '-P %s\n' "$MQTT_PASS" >> "$opts"

touch /tmp/fastcom-mqtt.ready

if [ -z "${MQTT_SERVER:-}" ]; then
  echo "[start.sh] MQTT_SERVER is not set; nothing to publish to. Idling." >&2
fi

while true; do
  if [ -n "${MQTT_SERVER:-}" ]; then
    echo "Running bandwidth test..."
    # UNVERIFIED: output of fast --json on the current fast.com page. Field names are from the fast-cli readme.
    if json="$(/app/fastcom/node_modules/.bin/fast --upload --json)"; then
      down="$(jq -r 'if .downloadUnit=="Gbps" then .downloadSpeed*1000 elif .downloadUnit=="Kbps" then .downloadSpeed/1000 else .downloadSpeed end' <<<"$json")"
      up="$(jq -r 'if .uploadUnit=="Gbps" then .uploadSpeed*1000 elif .uploadUnit=="Kbps" then .uploadSpeed/1000 else .uploadSpeed end' <<<"$json")"
      echo "down=${down} Mbps up=${up} Mbps; sending to MQTT (${MQTT_SERVER}:${MQTT_PORT})"
      mosquitto_pub -o "$opts" -h "$MQTT_SERVER" -p "$MQTT_PORT" -t "$MQTT_DOWN" -m "$down" || echo "publish of download value failed" >&2
      mosquitto_pub -o "$opts" -h "$MQTT_SERVER" -p "$MQTT_PORT" -t "$MQTT_UP" -m "$up" || echo "publish of upload value failed" >&2
    else
      echo "bandwidth test failed; retrying after ${SLEEP}s" >&2
    fi
  fi
  echo "Waiting for ${SLEEP} seconds..."
  sleep "$SLEEP"
done
