#!/usr/bin/env bash
set -euo pipefail

# With HOME=/config the app data folder resolves to /config/.gaseous-server (UNVERIFIED: check the app's data path code).
mkdir -p /config/.gaseous-server/Logs /config/.gaseous-server/Data

export ASPNETCORE_URLS="${ASPNETCORE_URLS:-http://+:5198}"

# DB and IGDB settings: apply from the environment on every start (protocol rule for databases).
# The mechanism is UNVERIFIED: env vars read by the app, or a config file rewritten from env on each start.
# Keep secrets out of files and the process list.

cd /app/gaseous-server
# The self-contained publish produces an apphost (UNVERIFIED for this csproj).
exec ./gaseous-server
