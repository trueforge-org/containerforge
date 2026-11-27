#!/usr/bin/env bash

set -euo pipefail

export TANOSHI_HOME="${TANOSHI_HOME:-/config}"

mkdir -p "$TANOSHI_HOME"/{plugins,downloads,manga} /tmp/tanoshi-cache

# Write the initial config only when it is missing; keep the existing secret on restarts.
if [ ! -s "$TANOSHI_HOME/config.yml" ]; then
  umask 077
  cat > "$TANOSHI_HOME/config.yml" <<EOF
port: ${PORT:-8080}
secret: "$(head -c 32 /dev/urandom | base64 | tr -d '\n')"
database_path: "$TANOSHI_HOME/tanoshi.db"
plugin_path: "$TANOSHI_HOME/plugins"
local_path: "$TANOSHI_HOME/manga"
download_path: "$TANOSHI_HOME/downloads"
cache_path: "/tmp/tanoshi-cache"
EOF
fi

# UNVERIFIED: the server bind address. Check it listens on all interfaces from outside the container.
# No tini wrapper: exec hands PID 1 signal handling straight to the server.
exec /app/tanoshi --config "$TANOSHI_HOME/config.yml"
