#!/usr/bin/env bash
set -eu

export SEMAPHORE_CONFIG_PATH="${SEMAPHORE_CONFIG_PATH:-/config/semaphore}"
export SEMAPHORE_DB_PATH="${SEMAPHORE_DB_PATH:-/config/semaphore}"
export SEMAPHORE_DB_DIALECT="${SEMAPHORE_DB_DIALECT:-sqlite}"
export SEMAPHORE_TMP_PATH="/tmp/semaphore"

# Create only missing directories. Existing files in /config are never touched.
mkdir -p "${SEMAPHORE_CONFIG_PATH}" "${SEMAPHORE_DB_PATH}" "${SEMAPHORE_TMP_PATH}" /tmp/ansible

# UNVERIFIED: upstream server-wrapper handles first-run setup (SEMAPHORE_FIRST_RUN, admin creation)
# and the config file layout. Replace the direct call below with the wrapper logic once it is read in full.
exec /usr/local/bin/semaphore server \
    --config "${SEMAPHORE_CONFIG_PATH}/config.json"
