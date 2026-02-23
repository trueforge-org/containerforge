#!/usr/bin/env bash
set -Eeuo pipefail

mkdir -p /config

if [[ ! -f /config/server.properties && -f /app/server.properties ]]; then
  cp /app/server.properties /config/server.properties
fi
