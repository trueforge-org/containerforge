#!/usr/bin/env bash

# Persistent state lives in /config. The bundle and entrypoint in /build are read-only at runtime.
mkdir -p /config/data
export WRITABLE_PATH="${WRITABLE_PATH:-/config/data}"
export PORT="${PORT:-8080}"

cd /build
# UNVERIFIED: the entrypoint may start a bundled FerretDB only when WEKAN_DB=ferretdb; the default uses MONGO_URL.
exec bash /build/wekan-entrypoint.sh
