#!/usr/bin/env bash
set -euo pipefail

# /app/rcon-web-admin/db is a symlink to /config/db (the app tree is read-only)
mkdir -p /config/db
if [[ -z "$(ls -A /config/db 2>/dev/null)" ]]; then
  cp -a /app/db-seed/. /config/db/
fi

# env.js exits with status 1 when RWA_ENV=TRUE and RWA_PASSWORD is empty,
# so env-based setup is enabled only when a password is given.
if [[ -n "${RWA_PASSWORD:-}" ]]; then
  export RWA_ENV=TRUE
else
  unset RWA_ENV
  echo "rcon-webadmin: RWA_PASSWORD not set, starting without env-based user/server setup" >&2
fi

cd /app/rcon-web-admin
exec node src/main.js start
