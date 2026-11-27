#!/usr/bin/env bash

echo "[10-copyconfig] Copying nginx config for BentoPDF"
mkdir -p /config
# nginx needs its temp parent dir to exist; /tmp is empty on each start.
mkdir -p /tmp/nginx-temp
# cp -n never overwrites user edits.
cp -n /defaults/nginx.conf /config/nginx.conf
