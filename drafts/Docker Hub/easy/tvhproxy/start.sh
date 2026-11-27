#!/usr/bin/env bash
set -euo pipefail

# All configuration comes from TVH_* environment variables read by tvhProxy.py.
# TVH_BINDADDR defaults to empty (all interfaces).
cd /app/tvhproxy
exec /app/venv/bin/python /app/tvhproxy/tvhProxy.py
