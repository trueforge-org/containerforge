#!/usr/bin/env bash
set -euo pipefail

# Seed the nginx config into /config only when missing. Never overwrite user edits.
mkdir -p /config
if [ ! -s /config/nginx.conf ]; then
    cp /defaults/nginx.conf /config/nginx.conf
fi

# nginx is the final exec so it receives signals. The site root is /app/site (read-only).
exec nginx -c /config/nginx.conf -g "daemon off;"
