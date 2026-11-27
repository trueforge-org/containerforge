#!/usr/bin/env bash
set -euo pipefail

export FILESTASH_PATH="${FILESTASH_PATH:-/config}"

mkdir -p \
    "${FILESTASH_PATH}/state/config" \
    "${FILESTASH_PATH}/state/certs" \
    "${FILESTASH_PATH}/state/plugins" \
    "${FILESTASH_PATH}/state/db" \
    "${FILESTASH_PATH}/state/search" \
    "${FILESTASH_PATH}/state/log" \
    /tmp/filestash-cache

# The app's TMP_PATH is <FILESTASH_PATH>/cache. Point it at /tmp so it stays ephemeral.
if [[ ! -e "${FILESTASH_PATH}/cache" ]]; then
    ln -s /tmp/filestash-cache "${FILESTASH_PATH}/cache"
fi

# config.json and general.secret_key are created by the app on first start.
cd /app/filestash
exec /app/filestash/filestash
