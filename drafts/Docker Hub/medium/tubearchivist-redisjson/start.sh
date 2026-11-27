#!/bin/bash
set -euo pipefail

REDIS_PASSWORD="${REDIS_PASSWORD:-}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_DATA_DIR="${REDIS_DATA_DIR:-/config}"
REDIS_APPENDONLY="${REDIS_APPENDONLY:-yes}"

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

mkdir -p "$REDIS_DATA_DIR"

args=(
  --bind 0.0.0.0
  --port "$REDIS_PORT"
  --dir "$REDIS_DATA_DIR"
)

# Same dump.rdb handling as apps/valkey/start.sh. An existing dump.rdb is ignored when AOF is on and no AOF exists yet,
# so load the snapshot first and turn AOF on once the server is up.
# UNVERIFIED: that Redis 8 behaves like Valkey here. Test with a dump.rdb in /config.
if [[ "$REDIS_APPENDONLY" == "yes" && -f "$REDIS_DATA_DIR/dump.rdb" && ! -d "$REDIS_DATA_DIR/appendonlydir" ]]; then
  args+=(--appendonly no)
  (
    export REDISCLI_AUTH="$REDIS_PASSWORD"
    until [[ "$(redis-cli -p "$REDIS_PORT" ping 2>/dev/null)" == "PONG" ]]; do
      sleep 1
    done
    redis-cli -p "$REDIS_PORT" config set appendonly yes >/dev/null
  ) &
else
  args+=(--appendonly "$REDIS_APPENDONLY")
fi

# UNVERIFIED: --requirepass puts the password in the process list, as apps/valkey does. redis-server has no password env var.
if [[ -n "$REDIS_PASSWORD" ]]; then
  args+=(--requirepass "$REDIS_PASSWORD")
fi

exec redis-server "${args[@]}" "$@"
