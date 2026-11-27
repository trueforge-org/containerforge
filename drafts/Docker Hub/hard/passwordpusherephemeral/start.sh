#!/usr/bin/env bash
set -euo pipefail

# /config holds storage/ (SQLite database and uploaded files). tmp/ and log/ go to /tmp.
mkdir -p /config/storage/db /tmp/pwpush/tmp /tmp/pwpush/log

if [ -z "${SECRET_KEY_BASE:-}" ] && [ -n "${SECRET_KEY_BASE_FILE:-}" ]; then
  SECRET_KEY_BASE="$(tr -d '[:space:]' < "${SECRET_KEY_BASE_FILE}")"
fi
if [ -z "${SECRET_KEY_BASE:-}" ]; then
  # Sessions reset on restart without a stable key. Set SECRET_KEY_BASE to keep them.
  echo "SECRET_KEY_BASE not set; generating one for this boot" >&2
  SECRET_KEY_BASE="$(ruby -rsecurerandom -e 'puts SecureRandom.hex(64)')"
fi
export SECRET_KEY_BASE

export DATABASE_URL="${DATABASE_URL:-sqlite3:storage/db/production.sqlite3}"
export HTTP_PORT="${HTTP_PORT:-8080}"
export TARGET_PORT="${TARGET_PORT:-5100}"

cd /app/passwordpusher

# Idempotent: db:migrate does nothing once the schema is current.
bundle exec rake db:migrate

prom="${PWP__PROMETHEUS__ENABLED:-false}"
metrics=0
if [ "${prom,,}" = "true" ]; then
  metrics=1
fi

workers=1
if [ -n "${PWP__NO_WORKER:-}" ] || [ -n "${PWP_PUBLIC_GATEWAY:-}" ]; then
  workers=0
fi

# UNVERIFIED: foreman is in the bundle and this matches the upstream entrypoint.
exec bundle exec foreman start -m "web=1,worker=${workers},metrics=${metrics}"
