#!/usr/bin/env bash

echo "[10-copyconfig] Copying nginx config file for Standard Notes web (only when missing)"
mkdir -p /config/sites
if [ ! -f /config/sites/default.conf ]; then
  cp /defaults/default.conf /config/sites/default.conf
fi
