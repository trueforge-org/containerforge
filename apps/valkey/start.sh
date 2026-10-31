#!/bin/bash
set -euo pipefail

VALKEY_PASSWORD="${VALKEY_PASSWORD:-${REDIS_PASSWORD:-}}"
VALKEY_PORT="${VALKEY_PORT:-${REDIS_PORT:-6379}}"
VALKEY_DATA_DIR="${VALKEY_DATA_DIR:-/config}"
VALKEY_APPENDONLY="${VALKEY_APPENDONLY:-yes}"

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

args=(
  --bind 0.0.0.0
  --port "$VALKEY_PORT"
  --dir "$VALKEY_DATA_DIR"
)

# Valkey ignores an existing dump.rdb when it starts with AOF on and has no AOF yet, so that data would be lost.
# Load the snapshot first, and turn AOF on once the server is up. This writes the loaded data to the AOF.
if [[ "$VALKEY_APPENDONLY" == "yes" && -f "$VALKEY_DATA_DIR/dump.rdb" && ! -d "$VALKEY_DATA_DIR/appendonlydir" ]]; then
  args+=(--appendonly no)
  (
    export VALKEYCLI_AUTH="$VALKEY_PASSWORD"
    until [[ "$(valkey-cli -p "$VALKEY_PORT" ping 2>/dev/null)" == "PONG" ]]; do
      sleep 1
    done
    valkey-cli -p "$VALKEY_PORT" config set appendonly yes >/dev/null
  ) &
else
  args+=(--appendonly "$VALKEY_APPENDONLY")
fi

if [[ -n "$VALKEY_PASSWORD" ]]; then
  args+=(--requirepass "$VALKEY_PASSWORD")
fi

exec valkey-server "${args[@]}" "$@"
