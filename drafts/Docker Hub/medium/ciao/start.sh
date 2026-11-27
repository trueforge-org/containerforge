#!/bin/bash
set -euo pipefail

# Symlink targets for /app (read-only at runtime). Idempotent.
mkdir -p /config/db /tmp/ciao/tmp/pids /tmp/ciao/log /tmp/ciao/storage /tmp/bootsnap

# Persist a generated secret so sessions survive restarts. Never printed, never on the command line.
if [[ -z "${SECRET_KEY_BASE:-}" ]]; then
  if [[ ! -s /config/secret_key_base ]]; then
    (umask 077 && cd /app && bundle exec rails secret > /config/secret_key_base)
  fi
  SECRET_KEY_BASE="$(cat /config/secret_key_base)"
  export SECRET_KEY_BASE
fi

cd /app
bundle exec rails db:migrate

rm -f /app/tmp/pids/server.pid

exec bundle exec rails server -b 0.0.0.0 -p 3000
