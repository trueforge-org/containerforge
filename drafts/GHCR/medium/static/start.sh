#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: the server serves the current directory with no flags (README). Confirm that,
# and that it listens on 0.0.0.0:8000 rather than localhost, on the first run.
mkdir -p /config
cd /config

exec /app/static/static
