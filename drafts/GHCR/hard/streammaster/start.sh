#!/usr/bin/env bash
set -euo pipefail

# Persistent state only. Nothing is written to /app.
mkdir -p /config/tv-logos
export TMPDIR=/tmp

cd /app
exec dotnet /app/StreamMaster.API.dll
