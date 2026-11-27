#!/usr/bin/env bash
set -eu

# /config holds the custom fonts and the DOCKER marker. /app/config is a build-time symlink to /config.
# UNVERIFIED: the app only checks for the DOCKER marker's existence.
mkdir -p /config/fonts
touch /config/DOCKER

cd /app
export NODE_ENV=production
# UNVERIFIED: the custom server binds to all interfaces; confirm in the probe run.
exec node dist/index.js
