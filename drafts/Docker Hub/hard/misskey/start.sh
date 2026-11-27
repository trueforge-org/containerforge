#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/files /tmp/.cache
cd /app/misskey

# Without MISSKEY_URL or DATABASE_PASSWORD, serve a stub on the port so the image still starts with no env.
if [[ -z "${MISSKEY_URL:-}" || -z "${DATABASE_PASSWORD:-}" ]]; then
  echo "MISSKEY_URL and DATABASE_PASSWORD are not set; starting a stub server on :${PORT:-3000}"
  exec node -e "require('http').createServer((q,r)=>{r.writeHead(200);r.end('Misskey needs MISSKEY_URL, DATABASE_PASSWORD, PostgreSQL and Valkey')}).listen(${PORT:-3000},'0.0.0.0')"
fi

# Seed the YAML config only when missing. url, port and DB credentials stay out of the file on purpose,
# so config.ts reads them from the environment on every start.
if [[ ! -s /config/default.yml ]]; then
  umask 077
  {
    echo "db:"
    echo "  host: '${DATABASE_HOST:-postgresql}'"
    echo "  port: ${DATABASE_PORT:-5432}"
    echo "redis:"
    echo "  host: '${REDIS_HOST:-valkey}'"
    echo "  port: ${REDIS_PORT:-6379}"
    if [[ -n "${REDIS_PASSWORD:-}" ]]; then
      echo "  pass: '${REDIS_PASSWORD//\'/\'\'}'"
    fi
    # Must never change after the first start.
    echo "id: 'aidx'"
  } > /config/default.yml
fi

# UNVERIFIED: run a DB migration before the server. Confirm the --migrate flag in scripts/start.mjs on build.
exec /usr/bin/tini -- node scripts/start.mjs --migrate
