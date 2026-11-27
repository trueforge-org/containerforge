#!/usr/bin/env bash

# Downloads are stored in /config, which is persistent. /app stays read-only.
mkdir -p /config/books
cd /config || exit 1

export BASE_PATH="${BASE_PATH:-/}"

# UNVERIFIED: the server must listen on all interfaces (0.0.0.0 or :8080); check the probe log.
exec /app/openbooks server \
    --dir /config/books \
    --port 8080
