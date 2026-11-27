#!/usr/bin/env bash

# Writes only to /config. Nothing is written under /app.
mkdir -p /config/logs

cd /config || exit 1

# UNVERIFIED: whether the server needs its own folder as cwd, and where it writes config and data.
exec /app/st-server/SkyrimTogetherServer
