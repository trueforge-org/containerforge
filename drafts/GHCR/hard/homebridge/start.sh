#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/node_modules /config/npm

cd /config
echo "Starting Homebridge on port 8581"
# UNVERIFIED: the -U flag and the homebridge binary path must be checked against the .deb.
exec homebridge -U /config
