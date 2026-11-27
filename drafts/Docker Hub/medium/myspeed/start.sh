#!/usr/bin/env bash

mkdir -p /config/data

cd /app/myspeed || exit 1
# UNVERIFIED for 1.0.9: the pinned 7290a975 Dockerfile runs `node server`. Confirm the entry point against the zip's package.json.
exec node server
