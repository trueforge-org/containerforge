#!/usr/bin/env bash

echo "[10-copyconfig] Copying nginx config file for Genea (existing user edits are kept)"
mkdir -p /config/sites
cp -n /defaults/default.conf /config/sites/default.conf
