#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config /tmp/frigate

# UNVERIFIED: a default config.yml is not shipped yet. Seed /config/config.yml only when it is missing
# (defaults/ to be added once a minimal valid config is confirmed).

cd /app/frigate
# UNVERIFIED: backend entry point and config path (python3 -m frigate is a guess from the upstream layout).
exec /app/frigate/venv/bin/python3 -m frigate
