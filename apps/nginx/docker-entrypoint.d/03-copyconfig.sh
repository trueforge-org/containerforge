#!/usr/bin/env bash

echo "[00-copyconfig] Copying default NGINX config files"
mkdir -p /config/sites
cp -n /defaults/nginx.conf  /config/nginx.conf
cp -n /defaults/default.conf /config/sites/default.conf
