#!/usr/bin/env bash

cp -n /defaults/adguardhome-sync.yaml /config/adguardhome-sync.yaml

cd /app
exec  /app/adguardhome-sync/adguardhome-sync run --config "${CONFIGFILE:-/config/adguardhome-sync.yaml}"

