#!/usr/bin/env bash
set -eu

CONFIG="${CONFIG:-/config}"
DATA="${DATA:-/config/assets}"
GIN_MODE="${GIN_MODE:-release}"

# Persistent state only under /config. /app/podgrab is read-only at runtime.
mkdir -p "${CONFIG}" "${DATA}"

export CONFIG DATA GIN_MODE

# The app reads client/ and webassets/ relative to its working directory.
cd /app/podgrab || exit 1
exec /app/podgrab/podgrab
