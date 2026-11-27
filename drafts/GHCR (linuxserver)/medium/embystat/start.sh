#!/usr/bin/env bash

mkdir -p /config/logs

# EmbyStat resolves its static GUI assets relative to its directory, so run from there.
# Bind address is UNVERIFIED: if Kestrel listens only on 127.0.0.1, set ASPNETCORE_URLS in the Dockerfile.
cd /app/embystat || exit 1

exec \
    /app/embystat/EmbyStat \
        --data-dir /config \
        --log-dir /config/logs \
        --config-dir /config \
        --enable-updates false
