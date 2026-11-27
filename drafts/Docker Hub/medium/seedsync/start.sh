#!/usr/bin/env bash
set -eu

CONFIG_DIR=/config
SETTINGS="${CONFIG_DIR}/settings.cfg"
DEFAULTS=/app/seedsync/defaults/settings.cfg

mkdir -p "${CONFIG_DIR}" /tmp/ssh

# Seed the default config only when missing or empty. Never overwrite user state.
if [ ! -s "${SETTINGS}" ]; then
    cp "${DEFAULTS}" "${SETTINGS}"
fi

export HOME=/tmp
# UNVERIFIED: python path and module layout inside the extracted .deb; replace with the deb's launcher if it has one.
exec /app/venv/bin/python /app/seedsync/python/seedsync.py \
    -c "${CONFIG_DIR}" \
    --html /app/seedsync/html \
    --scanfs /app/seedsync/scanfs
