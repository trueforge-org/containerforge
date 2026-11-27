#!/usr/bin/env bash
set -euo pipefail

# Files the app creates are group-writable, as upstream UMASK=002 did.
umask 002

# Temp and .NET cache stay in /tmp, and the image filesystem is read-only.
mkdir -p /config /tmp/dotnet
export DOTNET_URLS="${DOTNET_URLS:-http://+:7000}"

cd /app
# UNVERIFIED: the entry assembly name (AppHost.dll), because UseAppHost is off in the publish step. Check the publish output.
exec dotnet /app/AppHost.dll
