#!/usr/bin/env bash

echo "[10-copyconfig] Seeding nginx site config for AriaNg"
mkdir -p /config/sites
cp -n /defaults/default.conf /config/sites/default.conf
