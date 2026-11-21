#!/usr/bin/env bash

if [[ -n "${BASE_URL}" ]]; then
    EXTRA_PARAM="--baseurl ${BASE_URL}"
fi

# Ombi rewrites index.html at runtime (base url); /app is read-only
cp -f /defaults/index.html /tmp/index.html

cd /app
exec /app/Ombi --storage "/config" --host http://*:3579 ${EXTRA_PARAM}

