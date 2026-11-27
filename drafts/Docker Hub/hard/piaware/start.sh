#!/bin/bash
set -euo pipefail

# Hardware app. The four helpers run in one container: lighttpd (web UI), dump1090-fa (only with a receiver),
# and piaware. Without a receiver, the web UI and piaware still start, and the log says so.

mkdir -p /config/piaware /tmp/piaware /tmp/run/dump1090 /tmp/lighttpd

# Seed the config only when missing or empty, so user changes are kept.
if [[ ! -s /config/piaware/piaware.conf ]]; then
  cp /defaults/piaware.conf /config/piaware/piaware.conf
fi

export TZ="${TZ:-Etc/UTC}"

pids=()

cleanup() {
  if ((${#pids[@]} > 0)); then
    kill "${pids[@]}" 2>/dev/null || true
    wait 2>/dev/null || true
  fi
}
trap 'cleanup; exit 0' TERM INT

# Look for an RTL-SDR (USB character device under /dev/bus/usb).
# UNVERIFIED: the device check. It is a rough test and does not check the vendor ID.
receiver=false
if find /dev/bus/usb -mindepth 2 -maxdepth 2 -type c 2>/dev/null | grep -q .; then
  receiver=true
fi

if [[ "$receiver" == "true" ]]; then
  # UNVERIFIED: dump1090-fa flags. Beast output on 30005 and SBS on 30003 are the ports in settings.yaml.
  dump1090-fa --net --write-json /tmp/run/dump1090 &
  pids+=("$!")
else
  echo "No RTL-SDR device found under /dev/bus/usb. dump1090-fa is not started. Pass the USB device to the container to receive data."
fi

# Web UI on all interfaces, port 8080.
lighttpd -D -f /etc/piaware/lighttpd.conf &
pids+=("$!")

# UNVERIFIED: piaware flags (-configfile, -p, -plainlog). Upstream reads /etc/piaware.conf, which is read-only here.
piaware -configfile /config/piaware/piaware.conf -p /tmp/piaware/piaware.pid -plainlog &
pids+=("$!")

# Exit as soon as any child exits, so a failed helper stops the container.
status=0
wait -n "${pids[@]}" || status=$?
cleanup
exit "$status"
