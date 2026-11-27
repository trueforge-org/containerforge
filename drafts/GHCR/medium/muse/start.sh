#!/usr/bin/env bash


mkdir -p /config

if [[ -z "${DISCORD_TOKEN:-}" ]]; then
    echo "DISCORD_TOKEN is not set; Muse cannot connect to Discord." >&2
    exit 1
fi

cd /app/muse || exit 1
exec tini -- node --enable-source-maps dist/scripts/migrate-and-start.js
