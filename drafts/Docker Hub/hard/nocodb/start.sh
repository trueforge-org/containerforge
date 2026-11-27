#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/home

# Persist a JWT secret so sessions survive restarts when none is supplied
if [[ -z "${NC_AUTH_JWT_SECRET:-}" ]]; then
  if [[ ! -s /config/.jwt_secret ]]; then
    umask 077
    head -c 48 /dev/urandom | base64 | tr -d '\n=+/' > /config/.jwt_secret
  fi
  NC_AUTH_JWT_SECRET="$(cat /config/.jwt_secret)"
  export NC_AUTH_JWT_SECRET
fi

# Without NC_DB, NocoDB uses a SQLite file in /config (fine for testing, not for production)
if [[ -z "${NC_DB:-}" && -z "${NC_DB_JSON:-}" && -z "${NC_DB_JSON_FILE:-}" ]]; then
  echo "NC_DB not set: using local SQLite in /config"
fi

cd /config
exec /app/Noco
