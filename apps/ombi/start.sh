#!/usr/bin/env bash

cp /app/appsettings.json /config/appsettings.json

if [[ -n "${BASE_URL}" ]]; then
    EXTRA_PARAM="--baseurl ${BASE_URL}"
fi

exec /app/ombi/Ombi --storage "/config" --host http://*:3579 ${EXTRA_PARAM}

