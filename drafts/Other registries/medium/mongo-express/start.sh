#!/usr/bin/env bash

mkdir -p /config

export ME_CONFIG_MONGODB_URL="${ME_CONFIG_MONGODB_URL:-mongodb://mongodb:27017}"
export ME_CONFIG_BASICAUTH_ENABLED="${ME_CONFIG_BASICAUTH_ENABLED:-false}"

if [[ "${ME_CONFIG_BASICAUTH_ENABLED}" != "true" ]]; then
    echo "WARNING: ME_CONFIG_BASICAUTH_ENABLED is not true; the web UI has no login." >&2
fi

cd /app/mongo-express || exit 1
exec node app.js
