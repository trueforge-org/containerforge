#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/logs

# Seed the config only when missing or empty; never overwrite user state
if [[ ! -s /config/traccar.xml ]]; then
    cp /defaults/traccar.xml /config/traccar.xml
fi

# Relative database path (./data/database) resolves against the working directory,
# so run from /config to keep the H2 database on the persistent volume
cd /config

exec java \
    -XX:+ExitOnOutOfMemoryError \
    -jar /app/traccar/tracker-server.jar \
    /config/traccar.xml
