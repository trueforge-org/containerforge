#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. /app stays read-only.
for dir in library resources config assets; do
  mkdir -p "/config/romm/${dir}"
done

# Caches go to /tmp, never to /config or /app.
export XDG_CACHE_HOME=/tmp
export ROMM_PORT="${ROMM_PORT:-10680}"

# The auth secret comes from the environment. If it is empty, generate it once into /config.
# The value is never printed.
secret_file=/config/romm/.auth_secret_key
if [ -z "${ROMM_AUTH_SECRET_KEY:-}" ]; then
  if [ ! -s "${secret_file}" ]; then
    umask 077
    python3 -c 'import secrets; print(secrets.token_hex(32))' > "${secret_file}"
  fi
  ROMM_AUTH_SECRET_KEY="$(cat "${secret_file}")"
  export ROMM_AUTH_SECRET_KEY
fi

# Bounded wait for an external database and cache. Skipped when the host is not set.
wait_for() {
  local host="$1" port="$2" name="$3" tries=0
  while ! (exec 3<>"/dev/tcp/${host}/${port}") 2>/dev/null; do
    tries=$((tries + 1))
    if [ "${tries}" -ge 30 ]; then
      echo "ERROR: ${name} at ${host}:${port} is not reachable after ${tries} tries" >&2
      exit 1
    fi
    echo "Waiting for ${name} at ${host}:${port} (${tries}/30)"
    sleep 2
  done
}

if [ -n "${DB_HOST:-}" ]; then
  wait_for "${DB_HOST}" "${DB_PORT:-5432}" postgresql
fi
if [ -n "${REDIS_HOST:-}" ]; then
  wait_for "${REDIS_HOST}" "${REDIS_PORT:-6379}" valkey
fi

cd /app || exit 1
# UNVERIFIED: the gunicorn module path and the server entry point. Confirm against the 5.4.1 backend.
exec /app/venv/bin/gunicorn --bind "0.0.0.0:${ROMM_PORT}" --chdir /app/backend main:app
