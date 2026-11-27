#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: the migration command and the database variable it reads must be confirmed from apps/api
# Retry while PostgreSQL starts up; give up after a bounded number of attempts.
cd /app/peppermint/apps/api
migrated=0
for attempt in $(seq 1 30); do
  if npx prisma migrate deploy; then
    migrated=1
    break
  fi
  echo "database migration attempt ${attempt} failed, retrying in 5 seconds"
  sleep 5
done
if [[ "$migrated" -ne 1 ]]; then
  echo "database migration failed after 30 attempts" >&2
  exit 1
fi

cd /app/peppermint
exec pm2-runtime /app/peppermint/ecosystem.config.js
