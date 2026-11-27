#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /app/twonky

# Appdata (database, twonkyserver.ini, logs) goes to /config. The install directory stays read-only.
# UNVERIFIED: whether the server writes under /app/twonky at runtime. If it does, link those paths to /tmp here.
exec ./twonkyserver -appdata /config
