#!/usr/bin/env bash
set -euo pipefail

# config.py reads UPS_* from the environment. No wait for upsd: the UI starts without a reachable NUT server.
cd /app/webNUT
exec /app/venv/bin/pserve /app/webNUT/production.ini
