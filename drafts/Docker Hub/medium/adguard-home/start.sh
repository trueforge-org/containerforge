#!/usr/bin/env bash

mkdir -p /config/work

# Config is written by the setup wizard on first run; never seed or overwrite it here.
exec /app/AdGuardHome --no-check-update \
  -c /config/AdGuardHome.yaml \
  -w /config/work
