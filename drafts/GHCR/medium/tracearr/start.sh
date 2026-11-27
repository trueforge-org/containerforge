#!/usr/bin/env bash
set -eu

# persistent state and caches live in /config (an empty /config is fine)
mkdir -p /config/tracearr/image-cache /config/backups

export IMAGE_CACHE_DIR="${IMAGE_CACHE_DIR:-/config/tracearr/image-cache}"
mkdir -p "${IMAGE_CACHE_DIR}"

# print "host port" from scheme://[user[:pass]@]host[:port]/...
parse_url() {
  local url="$1" default_port="$2" hostport
  hostport="${url#*://}"
  hostport="${hostport##*@}"
  hostport="${hostport%%[/?]*}"
  if [[ "${hostport}" == *:* ]]; then
    echo "${hostport%%:*} ${hostport##*:}"
  else
    echo "${hostport} ${default_port}"
  fi
}

# bounded retry, logs each attempt; the server still starts after the last attempt
wait_for() {
  local name="$1" host="$2" port="$3" attempt
  for attempt in $(seq 1 30); do
    if (exec 3<>"/dev/tcp/${host}/${port}") 2>/dev/null; then
      echo "${name} reachable at ${host}:${port}"
      return 0
    fi
    echo "waiting for ${name} at ${host}:${port} (attempt ${attempt}/30)"
    sleep 2
  done
  echo "warning: ${name} not reachable at ${host}:${port}, starting anyway" >&2
}

if [[ -n "${DATABASE_URL:-}" ]]; then
  read -r db_host db_port < <(parse_url "${DATABASE_URL}" 5432)
  wait_for postgresql "${db_host}" "${db_port}"
fi

if [[ -n "${REDIS_URL:-}" ]]; then
  read -r redis_host redis_port < <(parse_url "${REDIS_URL}" 6379)
  wait_for valkey "${redis_host}" "${redis_port}"
fi

# UNVERIFIED: the upstream docker/entrypoint.sh (not read) may run migrations and generate secrets. Port those steps here before shipping.

cd /app/tracearr
exec node apps/server/dist/index.js
