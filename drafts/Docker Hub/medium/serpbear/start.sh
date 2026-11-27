#!/usr/bin/env bash
set -eu

export PORT="${PORT:-3000}"
export USER_NAME="${USER_NAME:-admin}"
export NEXT_PUBLIC_APP_URL="${NEXT_PUBLIC_APP_URL:-http://localhost:3000}"
export TZ="${TZ:-Etc/UTC}"

# /app/data is a symlink to /config/data. Create the folder only when it is missing.
mkdir -p /config/data

gen_secret() {
  head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n'
}

# SECRET and APIKEY: an explicit env value wins. Otherwise generate once and keep it in /config.
if [ -z "${SECRET:-}" ]; then
  if [ ! -s /config/.secret ]; then
    umask 077
    gen_secret > /config/.secret
  fi
  SECRET="$(cat /config/.secret)"
fi
export SECRET

if [ -z "${APIKEY:-}" ]; then
  if [ ! -s /config/.apikey ]; then
    umask 077
    gen_secret > /config/.apikey
  fi
  APIKEY="$(cat /config/.apikey)"
fi
export APIKEY

# Same as the upstream entrypoint: run migrations on every start. This is idempotent.
cd /app
npx sequelize-cli db:migrate --env production

# UNVERIFIED: that concurrently forwards SIGTERM cleanly. Check with docker stop.
exec npx concurrently "node server.js" "node cron.js"
