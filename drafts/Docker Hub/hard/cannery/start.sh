#!/usr/bin/env bash
# Starts the Cannery Elixir release. Runs on a read-only rootfs as UID 568.
# Persistent state lives in /config. Nothing is written to /app.
set -euo pipefail

# HOST has no safe default upstream. This default keeps the container starting for tests and
# must be replaced with the public hostname of the instance.
: "${HOST:=localhost}"
export HOST

UPLOADS_PATH="${UPLOADS_PATH:-/config/uploads}"
export UPLOADS_PATH
mkdir -p "${UPLOADS_PATH}"

# Generate a secret once and keep it in /config. A value set in the environment always wins.
# The value is never printed.
load_secret() {
  local var="$1" file="$2" bytes="$3"
  if [[ -z "${!var:-}" ]]; then
    if [[ ! -s "${file}" ]]; then
      umask 077
      openssl rand -base64 "${bytes}" | tr -d '\n' > "${file}"
    fi
    export "${var}=$(cat "${file}")"
  fi
}

# SECRET_KEY_BASE: any random string. CLOAK_KEY must base64-decode to exactly 32 bytes.
load_secret SECRET_KEY_BASE /config/secret_key_base 48
load_secret CLOAK_KEY /config/cloak_key 32

# Wait for PostgreSQL with bounded retries. Host and port come from DATABASE_URL.
if [[ -n "${DATABASE_URL:-}" ]]; then
  hostport="$(sed -E 's#^[^@]*@([^/]*)/.*$#\1#' <<< "${DATABASE_URL}")"
  db_host="${hostport%%:*}"
  db_port="5432"
  if [[ "${hostport}" == *:* ]]; then
    db_port="${hostport##*:}"
  fi
  for _ in $(seq 1 30); do
    if timeout 2 bash -c ": < /dev/tcp/${db_host}/${db_port}" 2>/dev/null; then
      break
    fi
    echo "waiting for database at ${db_host}:${db_port}" >&2
    sleep 2
  done
fi

# Migrations run at boot (prod sets automigrate: true in runtime.exs).
# RELEASE_COOKIE is set so the release does not try to write releases/COOKIE under the read-only /app.
RELEASE_COOKIE="${RELEASE_COOKIE:-$(openssl rand -hex 32)}"
export RELEASE_COOKIE

exec /app/bin/cannery start
