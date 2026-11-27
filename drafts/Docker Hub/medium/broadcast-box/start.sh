#!/usr/bin/env bash

# Stream profiles are written by the admin API, so they go to /config.
export STREAM_PROFILE_PATH="${STREAM_PROFILE_PATH:-/config/profiles}"
mkdir -p "${STREAM_PROFILE_PATH}"

# File logging writes ./logs under /app, which is read-only, so logs go to stdout by default.
export LOGGING_ENABLED="${LOGGING_ENABLED:-false}"
if [ "${LOGGING_ENABLED}" = "true" ]; then
  export LOGGING_DIRECTORY="${LOGGING_DIRECTORY:-/tmp/logs}"
  mkdir -p "${LOGGING_DIRECTORY}"
fi

# Fixed UDP port for WebRTC media so it can be published. Without it the port is random.
export UDP_MUX_PORT="${UDP_MUX_PORT:-8080}"
export NETWORK_TEST_ON_START="${NETWORK_TEST_ON_START:-false}"
export APP_ENV=production

# The app resolves ./web/build relative to the working directory.
cd /app
exec /app/broadcast-box
