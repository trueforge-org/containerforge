#!/usr/bin/env bash

# Persistent state lives under /config (config.json, SQLite database, uploads, logs)
mkdir -p "${GOKAPI_CONFIG_DIR:-/config/config}" "${GOKAPI_DATA_DIR:-/config/data}"

# Upstream sets TMPDIR to the data dir in Docker mode: upload chunks are moved into the data dir,
# which fails across filesystems (/tmp is a tmpfs here). Keep it on the data volume.
# UNVERIFIED: the native build needs this; confirm with an upload larger than 50 MB.
export TMPDIR="${TMPDIR:-${GOKAPI_DATA_DIR:-/config/data}}"
export GOKAPI_LOG_STDOUT="${GOKAPI_LOG_STDOUT:-true}"

cd /config
exec /app/gokapi
