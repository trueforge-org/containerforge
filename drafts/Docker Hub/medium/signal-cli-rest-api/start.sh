#!/usr/bin/env bash

mkdir -p /config/signal-cli

export PORT="${PORT:-8080}"
export SIGNAL_CLI_CONFIG_DIR="${SIGNAL_CLI_CONFIG_DIR:-/config/signal-cli}"
# UNVERIFIED: the REST server must find signal-cli on PATH via the /app/bin symlink
export PATH="/app/bin:${PATH}"

cd /app || exit 1
exec /app/signal-cli-rest-api
