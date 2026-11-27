#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /tmp/release
export RELEASE_TMP=/tmp/release
export DEFAULT_DATA_DIR=/config/data

# Secrets are generated once into /config (mode 600), never echoed or put on the command line
if [ -z "${SECRET_KEY_BASE:-}" ]; then
  if [ ! -s /config/secret_key_base ]; then
    (umask 077 && openssl rand -base64 48 > /config/secret_key_base)
  fi
  SECRET_KEY_BASE="$(cat /config/secret_key_base)"
  export SECRET_KEY_BASE
fi

# UNVERIFIED: TOTP_VAULT_KEY format (base64 of 32 bytes assumed)
if [ -z "${TOTP_VAULT_KEY:-}" ]; then
  if [ ! -s /config/totp_vault_key ]; then
    (umask 077 && openssl rand -base64 32 > /config/totp_vault_key)
  fi
  TOTP_VAULT_KEY="$(cat /config/totp_vault_key)"
  export TOTP_VAULT_KEY
fi

if [ -z "${DATABASE_URL:-}" ] || [ -z "${CLICKHOUSE_DATABASE_URL:-}" ]; then
  echo "WARNING: DATABASE_URL and/or CLICKHOUSE_DATABASE_URL is empty; plausible needs PostgreSQL and ClickHouse" >&2
fi

# Migrations run on every start. Retry while the databases come up.
run_db_step() {
  local name="$1" tries=0
  until "/app/${name}.sh"; do
    tries=$((tries + 1))
    if [ "${tries}" -ge 10 ]; then
      echo "ERROR: /app/${name}.sh failed after ${tries} attempts" >&2
      exit 1
    fi
    sleep 5
  done
}

# UNVERIFIED: script names; the entrypoint maps `db <name>` to /app/<name>.sh
run_db_step createdb
run_db_step migrate

exec /app/bin/plausible start
