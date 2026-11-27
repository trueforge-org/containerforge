#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

mkdir -p /config

# Seed config only when missing. Never overwrite user state.
if [ ! -f /config/config.yml ]; then
    cp /defaults/config.yml /config/config.yml
fi

# UNVERIFIED: the binary reads config/config.yml relative to its working directory, not /config.
# Wire the config path (env name UNVERIFIED, check src/invidious/config.cr) before merge.
# UNVERIFIED: upstream rewrites the DB host to invidious-db with sed. Apply DB host and password
# from the environment on every start, and keep them out of the process list.

cd /app/invidious
exec ./invidious
