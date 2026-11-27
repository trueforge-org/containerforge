#!/usr/bin/env bash
# Browserless start for ContainerForge. Writable state lives in /config and /tmp; /app is read-only at runtime.

# create directory structure
mkdir -p \
    /config/downloads \
    /config/metrics \
    /tmp/chrome-data

# Keep the unauthenticated endpoints closed by default: generate a TOKEN when none is set.
# The token is stored in /config/token (mode 600); its value is never logged.
if [[ -z "${TOKEN}" ]]; then
    if [[ -s /config/token ]]; then
        TOKEN="$(cat /config/token)"
    else
        # UNVERIFIED: openssl is present in the base image.
        TOKEN="$(openssl rand -hex 24)"
        (umask 077 && printf '%s' "${TOKEN}" > /config/token)
        echo "[browserless] no TOKEN set, generated one and stored it in /config/token"
    fi
    export TOKEN
fi

# UNVERIFIED: Chrome user data and download locations. Pass --user-data-dir=/tmp/chrome-data through the
# Browserless launch options, and check the env name for the downloads directory before pointing it at /config/downloads.

cd /app || exit 1
# UNVERIFIED: dumb-init is used by upstream scripts/start.sh; confirm it is in the base image.
exec dumb-init -- node build/index.js
