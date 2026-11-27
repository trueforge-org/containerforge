#!/usr/bin/env bash
set -euo pipefail

# Migrations run on every start (upstream CMD). Run from the app dir so ./drizzle resolves. Nothing is written to /app.
cd /app/streamystats-job-server

if ! ./migrate-bin; then
  echo "migrate-bin failed; check the database settings" >&2
  exit 1
fi

exec ./server
