#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-8080}"
export CONFIG_PATH="${CONFIG_PATH:-/config/}"
export DB_DRIVER="${DB_DRIVER:-sqlite}"
export DB_PORT="${DB_PORT:-5432}"

mkdir -p "${CONFIG_PATH}"

# API_SECRET: the app falls back to a public value when unset, so persist a generated one
# so JWTs survive restarts
if [ -z "${API_SECRET:-}" ]; then
  [ -s /config/.api_secret ] || (umask 077; head -c 32 /dev/urandom | base64 > /config/.api_secret)
  API_SECRET="$(cat /config/.api_secret)"
fi
export API_SECRET

# UNVERIFIED / needs a maintainer decision: upstream POSTs every uploaded PDF to
# https://pdf2png.sheetable.net with TLS verification disabled, and no env var turns this off.
cd /config
exec /app/sheetable
