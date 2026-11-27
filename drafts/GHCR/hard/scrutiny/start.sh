#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config/config

cd /config

# UNVERIFIED: the web binary subcommand, config path flag and bind address (0.0.0.0:8080) must be confirmed
# from `scrutiny-web --help` on the first build. Keep exec so signals reach the server.
exec /app/bin/scrutiny-web start
