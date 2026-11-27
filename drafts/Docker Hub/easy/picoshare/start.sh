#!/usr/bin/env bash
set -euo pipefail

DB_PATH="/config/store.db"
export DB_PATH # litestream.yml references ${DB_PATH}
mkdir -p /config
cd /config

# The binary refuses to start without a passphrase. Generate one once and keep
# it in a file (never on the command line or in the log).
if [[ -z "${PS_SHARED_SECRET:-}" && -z "${PS_SHARED_SECRET_FILE:-}" ]]; then
  SECRET_FILE=/config/shared_secret
  if [[ ! -s "${SECRET_FILE}" ]]; then
    ( umask 077; tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 >"${SECRET_FILE}" ) || true
    echo "PS_SHARED_SECRET not set: generated an admin passphrase in ${SECRET_FILE}"
  fi
  export PS_SHARED_SECRET_FILE="${SECRET_FILE}"
fi

if [[ -n "${LITESTREAM_BUCKET:-}" ]]; then
  [[ -f "${DB_PATH}" ]] || /app/litestream restore -if-replica-exists "${DB_PATH}"
  exec /app/litestream replicate -exec "/app/picoshare -db ${DB_PATH}"
fi

exec /app/picoshare -db "${DB_PATH}"
