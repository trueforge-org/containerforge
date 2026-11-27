#!/bin/bash
set -euo pipefail

# Embedded valkey (used when XO_REDIS_URI is empty) and xo-server run in one container.
# The final process is xo-server (exec), so valkey is a child of it, and tini (PID 1 in the base) forwards signals.

config_dir="/config/.config/xo-server"
config_file="$config_dir/config.toml"
mkdir -p /config/data /config/redis "$config_dir"

if [[ -n "${XO_REDIS_URI:-}" ]]; then
  REDIS_URI="$XO_REDIS_URI"
else
  REDIS_URI="redis://127.0.0.1:6379/0"
  # Internal valkey, bound to loopback only. Data goes to /config/redis, with appendonly for durability.
  valkey-server --bind 127.0.0.1 --port 6379 --dir /config/redis --appendonly yes --daemonize no &
  for _ in $(seq 1 30); do
    if valkey-cli -p 6379 ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi
export REDIS_URI HTTP_PORT="${HTTP_PORT:-8080}"

# Render the config once, and never overwrite user edits.
if [[ ! -s "$config_file" ]]; then
  envsubst '${HTTP_PORT} ${REDIS_URI}' < /defaults/config.toml.tmpl > "$config_file"
fi

cd /app/xen-orchestra/packages/xo-server
exec node dist/cli.mjs
