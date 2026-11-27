#!/usr/bin/env bash
set -euo pipefail

# State lives in /config only. Caches go to /tmp.
mkdir -p /config/prefs /config/logs /tmp/lms-cache

cd /config
# UNVERIFIED: the entry script (slimserver.pl), the directory names and every flag below. Take them from the
# upstream start-container.sh and `slimserver.pl --help` before the first build. The upstream script also
# handles PUID/PGID and the root remap, which this image drops on purpose.
exec perl /app/lyrion-music-server/slimserver.pl \
  --prefsdir /config/prefs \
  --logdir /config/logs \
  --cachedir /tmp/lms-cache \
  --httpport "${HTTP_PORT:-9000}"
