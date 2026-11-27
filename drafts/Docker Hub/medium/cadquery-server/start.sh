#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/scripts
if ! compgen -G "/config/scripts/*.py" > /dev/null; then
    cp -n /defaults/example.py /config/scripts/
fi

# Keep matplotlib cache and bytecode out of /config and /app
export MPLCONFIGDIR=/tmp/matplotlib
export PYTHONDONTWRITEBYTECODE=1

cd /config/scripts
exec /app/cq-venv/bin/cq-server run -p 5000 .
