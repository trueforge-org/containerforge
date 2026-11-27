#!/usr/bin/env bash

set -euo pipefail

export HOME=/tmp
export INTERVAL="${INTERVAL:-8}"
export HISTORY_SIZE="${HISTORY_SIZE:-450}"
READSB_EXTRA_ARGS="${READSB_EXTRA_ARGS:-}"
READSB_NET_CONNECTOR="${READSB_NET_CONNECTOR:-}"
READSB_DEVICE_TYPE="${READSB_DEVICE_TYPE:-}"

mkdir -p /config/globe_history /tmp/run/readsb /tmp/run/tar1090 /tmp/nginx-temp

# Seed the site config once. Never overwrite user edits.
if [[ ! -f /config/config.js ]]; then
    cp /defaults/config.js /config/config.js
fi

readsb_args=(
    --net
    --write-json /tmp/run/readsb
    --write-globe-history /config/globe_history
    --net-api-port 0
)
# UNVERIFIED: --net-api-port 0, --net-connector and --device-type names against the pinned readsb help output.
if [[ -n "${READSB_NET_CONNECTOR}" ]]; then
    readsb_args+=(--net-connector "${READSB_NET_CONNECTOR}")
fi
if [[ -n "${READSB_DEVICE_TYPE}" ]]; then
    readsb_args+=(--device-type "${READSB_DEVICE_TYPE}")
fi
read -r -a extra_args <<< "${READSB_EXTRA_ARGS}"
readsb_args+=("${extra_args[@]}")

/usr/local/bin/readsb "${readsb_args[@]}" &

# UNVERIFIED: tar1090.sh argument order; read the script header before the first run.
/app/tar1090/tar1090.sh /tmp/run/tar1090 /tmp/run/readsb &

# If any child exits, stop the container so the failure is visible.
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

nginx -c /config/nginx.conf -g 'daemon off;' &

wait -n
echo "a tar1090 process exited, stopping the container"
exit 1
