#!/usr/bin/env bash
set -euo pipefail

# The UI is stateless; /config is kept for future state.
mkdir -p /config

exec nginx -c /etc/batnoter/nginx.conf -g 'daemon off;'
