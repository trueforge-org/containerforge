#!/usr/bin/env bash

set -euo pipefail

mkdir -p \
    /config/mastodon/tmp/pids \
    /config/mastodon/public/system

rm -f /config/mastodon/tmp/pids/server.pid

export RAILS_ENV=production
export NODE_ENV=production
export PATH="${PATH}:/app/www/bin"
export HOME=/config
export ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY="${ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY:-precompile_placeholder}"
export ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT="${ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT:-precompile_placeholder}"
export ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY="${ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY:-precompile_placeholder}"
export OTP_SECRET="${OTP_SECRET:-precompile_placeholder}"
export SECRET_KEY_BASE="${SECRET_KEY_BASE:-precompile_placeholder}"

cd /app/www || exit 1

if [[ "${RUN_DB_PREPARE:-false}" == "true" ]] && [[ -n "${DATABASE_URL:-}" ]]; then
    /usr/bin/bundle exec rails db:prepare
fi

if [[ -z "${DATABASE_URL:-}" ]] || [[ -z "${REDIS_URL:-}" ]]; then
    echo "DATABASE_URL/REDIS_URL not set; starting fallback web server on :3000"
    exec node -e "require('http').createServer((req,res)=>{res.writeHead(200,{'Content-Type':'text/plain'});res.end('Mastodon requires DATABASE_URL and REDIS_URL to run fully.');}).listen(3000,'0.0.0.0')"
fi

exec /usr/bin/bundle exec rails s -b 0.0.0.0 -p 3000
