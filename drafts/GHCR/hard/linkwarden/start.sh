#!/usr/bin/env bash
# UNVERIFIED draft (plan section 7): the DB and auth variable names are not confirmed from docs.linkwarden.app.
set -euo pipefail

# Persistent data lives in /config. /app/linkwarden is read-only at runtime.
mkdir -p /config/data /tmp/next-cache

# Run database migrations, retrying while PostgreSQL starts. Exit non-zero if it never answers.
# UNVERIFIED: schema path (plan section 7).
attempt=0
until npx prisma migrate deploy --schema /app/linkwarden/packages/prisma/schema.prisma; do
  attempt=$((attempt + 1))
  if [ "${attempt}" -ge 30 ]; then
    echo "prisma migrate deploy failed after ${attempt} attempts" >&2
    exit 1
  fi
  sleep 2
done

cd /app/linkwarden

# Replace the upstream sh -c CMD so the supervisor (concurrently) is PID 1 and receives signals.
# UNVERIFIED: script names must match upstream package.json (plan section 7).
exec npx concurrently -k "yarn workspace @linkwarden/web start" "yarn workspace @linkwarden/worker start"
