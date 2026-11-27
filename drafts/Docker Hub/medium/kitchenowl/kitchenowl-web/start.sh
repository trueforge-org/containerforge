#!/usr/bin/env bash
set -euo pipefail

BACK_URL="${BACK_URL:-kitchenowl:8080}"

mkdir -p /config/sites

# Seed the config files only when missing. Never overwrite user state.
if [ ! -s /config/nginx.conf ]; then
  cp /defaults/nginx.conf /config/nginx.conf
fi
if [ ! -s /config/sites/default.conf ]; then
  sed "s|__BACK_URL__|${BACK_URL}|g" /defaults/default.conf > /config/sites/default.conf
fi

exec nginx -c /config/nginx.conf -g "daemon off;"
