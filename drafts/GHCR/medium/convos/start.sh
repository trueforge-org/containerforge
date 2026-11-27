#!/usr/bin/env bash
set -euo pipefail

# Convos creates its own data on first run; nothing is seeded
mkdir -p /config

export CONVOS_HOME="${CONVOS_HOME:-/config}"

cd /app
# UNVERIFIED: listen flag form (-l http://*:3000); bind all interfaces for use from other containers
exec /app/script/convos daemon -l "http://*:3000"
