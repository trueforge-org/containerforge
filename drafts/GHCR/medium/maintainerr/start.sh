#!/bin/sh
set -eu

# Upstream start logic; paths moved from /opt/data to DATA_DIR (default /config). /app is never written.
DATA_DIR="${DATA_DIR:-/config}"
BASE_PATH_REPLACE="${BASE_PATH:-}"
BUNDLED_UI_DIR="/app/maintainerr/apps/server/dist/ui"
SERVED_UI_DIR="${DATA_DIR}/ui"

mkdir -p "${DATA_DIR}/logs"

# Rebuild the staged UI on every boot so upgrades and BASE_PATH changes never leave stale files.
if [ -d "$SERVED_UI_DIR" ]; then
  chmod -R u+w "$SERVED_UI_DIR" 2>/dev/null || true
fi
rm -rf "$SERVED_UI_DIR"
mkdir -p "$SERVED_UI_DIR"
cp -R "$BUNDLED_UI_DIR/." "$SERVED_UI_DIR/"
chmod -R u+w "$SERVED_UI_DIR"
# UNVERIFIED: the server reads the UI from ${DATA_DIR}/ui; confirm with grep in the build stage
find "$SERVED_UI_DIR" -type f -print0 | xargs -0 sed -i "s,/__PATH_PREFIX__,${BASE_PATH_REPLACE},g"

cd /app/maintainerr/apps/server
npm_package_version="$(node -p "require('./package.json').version" 2>/dev/null || true)"
export npm_package_version
export DATA_DIR UI_PORT UI_HOSTNAME NODE_ENV DEBUG

exec node dist/main
