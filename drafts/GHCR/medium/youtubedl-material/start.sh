#!/usr/bin/env bash

set -eu

# data paths are symlinked from /app into /config (links created at build time)
mkdir -p \
    /config/appdata \
    /config/users \
    /config/subscriptions \
    /config/audio \
    /config/video

cd /app

# UNVERIFIED: entry file (app.js) is not confirmed. Upstream `npm start` runs pm2-runtime, which is dropped here
# so that node is PID 1 under exec. Confirm the entry in the v4.3.2 zip before the first build.
exec node app.js
