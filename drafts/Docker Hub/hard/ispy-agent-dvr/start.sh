#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives under /config. /app is read-only at runtime.
mkdir -p /config/Media/XML /config/Media/WebServerRoot/Media /config/Media/Models /config/Commands /tmp/dotnet

cd /app
# UNVERIFIED: the Agent listens on 8090 on all interfaces by default. Check with ss -ltn in the probe.
exec /app/Agent
