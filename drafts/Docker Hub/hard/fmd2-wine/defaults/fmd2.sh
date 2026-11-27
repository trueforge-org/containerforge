#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config/FMD2 /downloads /tmp/cache

# Seed FMD2 data into /config only where it is missing; never overwrite user state.
for d in userdata lua data; do
  mkdir -p "/config/FMD2/$d"
  cp -rn "/usr/share/fmd2-defaults/$d/." "/config/FMD2/$d/"
done

# The first start builds the Wine prefix, which takes minutes.
if [ ! -d /config/.wine ]; then
  wineboot --init
fi

cd /app/FMD2
# UNVERIFIED: the executable name inside the release archive.
exec wine /app/FMD2/fmd.exe
