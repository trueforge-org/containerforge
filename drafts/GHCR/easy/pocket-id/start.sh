#!/usr/bin/env bash
set -euo pipefail

# The app resolves its default paths (data/pocket-id.db, data/uploads) relative
# to the working directory, so run from /config to keep state on the volume.
mkdir -p /config/data
cd /config

export APP_URL="${APP_URL:-http://localhost:1411}"
export DB_CONNECTION_STRING="${DB_CONNECTION_STRING:-file:data/pocket-id.db}"
export ANALYTICS_DISABLED="${ANALYTICS_DISABLED:-true}"

case "${APP_URL}" in
    https://*) ;;
    *) echo "Warning: APP_URL is not https; passkeys need a secure public origin. Set APP_URL to the public address." >&2 ;;
esac

exec /app/pocket-id
