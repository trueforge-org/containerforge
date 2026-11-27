#!/usr/bin/env bash
set -euo pipefail

export VIKUNJA_SERVICE_ROOTPATH="${VIKUNJA_SERVICE_ROOTPATH:-/config}"
export VIKUNJA_DATABASE_PATH="${VIKUNJA_DATABASE_PATH:-/config/vikunja.db}"
export VIKUNJA_FILES_BASEPATH="${VIKUNJA_FILES_BASEPATH:-/config/files}"
export VIKUNJA_LOG_PATH="${VIKUNJA_LOG_PATH:-/tmp/vikunja-logs}"
export VIKUNJA_SERVICE_INTERFACE="${VIKUNJA_SERVICE_INTERFACE:-:3456}"

mkdir -p "${VIKUNJA_FILES_BASEPATH}" "$(dirname "${VIKUNJA_DATABASE_PATH}")" "${VIKUNJA_LOG_PATH}"

# Stable secret across restarts: generate once, never overwrite. Without it,
# Vikunja picks a random one on every start and all sessions are invalidated.
if [ -z "${VIKUNJA_SERVICE_SECRET:-}" ]; then
  if [ ! -s /config/.service_secret ]; then
    (umask 077; head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/.service_secret)
  fi
  VIKUNJA_SERVICE_SECRET="$(cat /config/.service_secret)"
  export VIKUNJA_SERVICE_SECRET
fi

cd /config
exec /app/vikunja/vikunja
