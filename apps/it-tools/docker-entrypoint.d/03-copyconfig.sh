#!/usr/bin/env bash

echo "[03-copyconfig] Copying nginx config file for IT-Tools"
mkdir -p /config/sites
cp /defaults/default.conf /config/sites/default.conf
