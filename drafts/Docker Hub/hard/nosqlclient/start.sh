#!/usr/bin/env bash
set -euo pipefail

# Port of the upstream entrypoint.sh without the local mongod.
mkdir -p /tmp/home /config
export HOME=/tmp/home TMPDIR=/tmp

# Support NAME_FILE for the secret-like variables. Setting both forms is an error.
resolve_file_var() {
  local name="$1"
  local file_var="${name}_FILE"
  if [ -n "${!file_var:-}" ]; then
    if [ -n "${!name:-}" ]; then
      echo "ERROR: set ${name} or ${file_var}, not both" >&2
      exit 1
    fi
    printf -v "${name}" '%s' "$(cat "${!file_var}")"
    export "${name}"
  fi
}
for v in MONGO_URL MONGO_USERNAME MONGO_PASSWORD; do
  resolve_file_var "${v}"
done

# Percent-encode through node12 so the values never appear in argv.
urlenc() {
  V="$1" /usr/local/bin/node12 -e 'process.stdout.write(encodeURIComponent(process.env.V))'
}

if [ -z "${MONGO_URL:-}" ]; then
  auth=""
  if [ -n "${MONGO_USERNAME:-}" ]; then
    auth="$(urlenc "${MONGO_USERNAME}")"
    if [ -n "${MONGO_PASSWORD:-}" ]; then
      auth="${auth}:$(urlenc "${MONGO_PASSWORD}")"
    fi
    auth="${auth}@"
  fi
  opts="ssl=${MONGO_TLS:-false}"
  if [ -n "${MONGO_OPT_PARAMS:-}" ]; then
    opts="${opts}&${MONGO_OPT_PARAMS}"
  fi
  export MONGO_URL="${MONGO_SCHEME:-mongodb}://${auth}${MONGO_ADDRESSES:-127.0.0.1:27017}/${MONGO_DATABASE:-meteor}?${opts}"
fi

if [[ "${MONGO_URL}" == *127.0.0.1* ]]; then
  echo "WARNING: MONGO_URL points at 127.0.0.1, and this image has no MongoDB. Set MONGO_URL to a reachable server." >&2
fi

# Use the predefined connections file from /config when it exists and no path is set.
if [ -z "${MONGOCLIENT_CONNECTIONS_FILE_PATH:-}" ] && [ -f /config/predefined_connections.json ]; then
  export MONGOCLIENT_CONNECTIONS_FILE_PATH=/config/predefined_connections.json
fi

if [ -n "${STARTUP_DELAY:-}" ]; then
  sleep "${STARTUP_DELAY}"
fi

echo "=> Starting app on port ${PORT:-3000}..."
cd /app
exec /usr/local/bin/node12 main.js
