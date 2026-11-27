#!/usr/bin/env bash

: "${DB_PASSWORD:?DB_PASSWORD must be set}"

mkdir -p /config/data /tmp/immich

cd /app/immich/server
# UNVERIFIED: the entry point (node dist/main.js) must be confirmed from the v3.4.2 source before the first run.
exec tini -- node dist/main.js
