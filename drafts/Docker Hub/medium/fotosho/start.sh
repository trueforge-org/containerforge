#!/usr/bin/env bash

# UNVERIFIED: data directory used by the app (njodb); create only what is confirmed
mkdir -p /config/data

cd /app/fotosho || exit 1
exec node index.js
