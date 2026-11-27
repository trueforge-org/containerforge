#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export TMPDIR=/tmp

FOSSIL_PORT="${FOSSIL_PORT:-8080}"
REPO_FILE="/config/repos/default.fossil"

mkdir -p /config/repos

# Create the default repository only on first start, never overwrite it.
if [ ! -f "${REPO_FILE}" ]; then
    fossil new "${REPO_FILE}"
fi

# UNVERIFIED: the exact fossil server flags are not confirmed for the Ubuntu build.
# Confirm with `fossil help server` in the built image before relying on them.
exec fossil server --port "${FOSSIL_PORT}" --ipaddr 0.0.0.0 "${REPO_FILE}"
