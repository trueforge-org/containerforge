#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# UNVERIFIED: first-run file layout under /config, and whether the server binds 0.0.0.0.
# Check both in the log on an empty-volume run. If it binds only localhost, add the bind flag the binary provides.
cd /app
exec /app/muximux --data /config
