#!/usr/bin/env bash

echo "[10-copyconfig] Copying nginx site config for wifi-card"
mkdir -p /config/sites
cp /defaults/default.conf /config/sites/default.conf
