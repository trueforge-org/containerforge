#!/usr/bin/env bash
set -euo pipefail

umask 077
mkdir -p /config

# Use the key from the environment; otherwise persist a random one in /config
# so sessions survive restarts. Never passed as an argument.
if [ -z "${SHIORI_HTTP_SECRET_KEY:-}" ]; then
    if [ ! -s /config/.secret_key ]; then
        head -c 32 /dev/urandom | base64 > /config/.secret_key
    fi
    SHIORI_HTTP_SECRET_KEY="$(cat /config/.secret_key)"
    export SHIORI_HTTP_SECRET_KEY
fi

umask 022
cd /config
exec /app/shiori server
