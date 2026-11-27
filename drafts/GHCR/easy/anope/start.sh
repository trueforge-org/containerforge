#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
mkdir -p /config
cd /config

# Seed the services config only when it is missing. Never overwrite user state.
if [ ! -f /config/services.conf ]; then
    cp /defaults/services.conf /config/services.conf
fi

# UNVERIFIED: flags must be checked against `anope --help` for the 2.0.17 apt build.
# Foreground run (PID 1 via exec), config and databases kept in /config.
exec anope --nofork --confdir=/config --datadir=/config
