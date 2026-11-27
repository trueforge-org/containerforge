#!/usr/bin/env bash
set -euo pipefail

# Ports are set by flags (-p http, -P https), not env vars. Non-root cannot bind 80/443.
cd /app
exec /app/nullserv -p 8080 -P 8443 "$@"
