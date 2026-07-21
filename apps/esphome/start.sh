#!/usr/bin/env bash

PLATFORMIO_CORE_DIR=${PLATFORMIO_CORE_DIR:-/tmp/pio}
ESPHOME_BUILD_PATH=${ESPHOME_BUILD_PATH:-/tmp/build}
ESPHOME_DATA_DIR=${ESPHOME_DATA_DIR:-/tmp/data}

# Make sure cache folders exist
mkdir -p "${PLATFORMIO_CORE_DIR}"
mkdir -p "${ESPHOME_BUILD_PATH}"
mkdir -p "${ESPHOME_DATA_DIR}"

# Prune PIO files
pio system prune --force

# Route the default dashboard command to Device Builder, but keep the rest
# of the ESPHome CLI available for compile/run/logs.
if [[ "${1:-}" == "dashboard" ]]; then
	shift
	exec /usr/local/bin/esphome-device-builder "$@"
fi

exec /usr/local/bin/esphome "$@"
