#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# The TrueCharts chart creates /config/notifiarr.conf before start so the client does not generate a
# default password (UNVERIFIED for this binary). Create it only when missing, never overwrite it.
if [ ! -f /config/notifiarr.conf ]; then
  printf '%s\n' '# Dummy comment' > /config/notifiarr.conf
fi

cd /config
exec /app/notifiarr
