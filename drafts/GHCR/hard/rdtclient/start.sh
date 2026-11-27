#!/usr/bin/env bash

# Only /config is writable at runtime. Create the XDG config folder when it is missing.
mkdir -p /config/xdg

cd /app || exit 1
# UNVERIFIED: the entry assembly name. Confirm it from the zip before the first run.
# UNVERIFIED: the upstream data paths (/data/db, /data/downloads) and their env names. Not remapped yet.
exec dotnet /app/RdtClient.Server.dll
