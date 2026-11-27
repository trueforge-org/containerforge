#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export DOTNET_CLI_HOME=/tmp/dotnet

NPVR_APP=/app/nextpvr

mkdir -p /config

# Seed the shipped defaults only when /config is empty. /app is read-only at runtime.
# UNVERIFIED: the data directory is /config. The real switch (command line, env or appsettings.json)
# is not confirmed. Do not guess it, check NextPVRServer.dll options before the first run.
if [ -z "$(ls -A /config)" ] && [ -d "${NPVR_APP}/data" ]; then
    cp -a "${NPVR_APP}/data/." /config/
fi

cd "${NPVR_APP}"
exec dotnet NextPVRServer.dll
