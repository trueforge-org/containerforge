#!/usr/bin/env bash
set -euo pipefail

# Next.js reads its own build; nothing is written to /app. Config and state belong in /config.
mkdir -p /config

cd /app/streamystats/apps/nextjs-app
exec node server.js
