#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/gate-cache
cd /config

# UNVERIFIED: Gate's config file name and default location, and whether it starts with an empty /config
# (it may generate a default config). Check the Gate docs or `gate --help` on the built image before
# adding a seeded default under /defaults/ with `cp -n`.
exec /app/gate "$@"
