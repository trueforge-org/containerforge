#!/usr/bin/env bash

if [[ -n "${BASE_URL}" ]]; then
    EXTRA_PARAM="--baseurl ${BASE_URL}"
fi

cd /app
exec /app/Ombi --storage "/config" --host http://*:3579 ${EXTRA_PARAM}

