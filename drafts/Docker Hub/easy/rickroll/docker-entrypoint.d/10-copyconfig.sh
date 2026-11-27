#!/usr/bin/env bash

echo "[10-copyconfig] Copying nginx server config for Rickroll"
mkdir -p /config/sites
cp /defaults/default.conf /config/sites/default.conf
