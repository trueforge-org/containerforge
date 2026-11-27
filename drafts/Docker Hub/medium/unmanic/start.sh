#!/usr/bin/env bash

mkdir -p /config /tmp/unmanic

cd /config
# UNVERIFIED: console script name "unmanic" in /app/venv/bin until the wheel is installed and listed.
exec /app/venv/bin/unmanic
