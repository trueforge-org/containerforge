#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
CONFIG_PATH="${CONFIG_PATH:-/config/config.yml}"

# Defaults for the first start. Mango reads these env vars only when the
# option is missing from the config file (file > env > default).
export HOST="0.0.0.0"
export PORT="${PORT:-9000}"
export LIBRARY_PATH="${LIBRARY_PATH:-/data}"
export DB_PATH="${DB_PATH:-/config/mango.db}"
export QUEUE_DB_PATH="${QUEUE_DB_PATH:-/config/queue.db}"
export LIBRARY_CACHE_PATH="${LIBRARY_CACHE_PATH:-/config/library.yml.gz}"
export UPLOAD_PATH="${UPLOAD_PATH:-/config/uploads}"
export PLUGIN_PATH="${PLUGIN_PATH:-/config/plugins}"
export SCAN_INTERVAL_MINUTES="${SCAN_INTERVAL_MINUTES:-5}"
export LOG_LEVEL="${LOG_LEVEL:-info}"
export TMPDIR=/tmp

mkdir -p /config/uploads /config/plugins "$(dirname "${CONFIG_PATH}")"

# Only used while the config file does not exist yet; afterwards the file wins.
if [ ! -f "${CONFIG_PATH}" ] && [ -z "${SESSION_SECRET:-}" ]; then
  SESSION_SECRET="$(head -c 32 /dev/urandom | base64 | tr -d '/+=\n')"
fi
# An empty value must never be exported, or Mango would use it as the secret.
if [ -n "${SESSION_SECRET:-}" ]; then
  export SESSION_SECRET
fi

exec /app/mango -c "${CONFIG_PATH}"
