#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: DATABASE_URL is required (postgres URL, e.g. postgres://user:pass@postgresql:5432/miniflux?sslmode=disable)" >&2
  exit 1
fi

cd /app/miniflux
exec /app/miniflux/miniflux
