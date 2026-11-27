#!/usr/bin/env bash
set -euo pipefail

CONFIGFILE="${CONFIGFILE:-/config/glauth.cfg}"

mkdir -p "$(dirname "${CONFIGFILE}")"
# Seed only when missing. Never overwrite an existing config.
if [ ! -f "${CONFIGFILE}" ]; then
  echo "[glauth] ${CONFIGFILE} not found, seeding minimal default config"
  cp /defaults/glauth.cfg "${CONFIGFILE}"
fi

/app/glauth --version || true
cd /config
exec /app/glauth -c "${CONFIGFILE}"
