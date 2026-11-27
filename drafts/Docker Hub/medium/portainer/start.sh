#!/bin/sh
set -eu

if [ "${1:-}" = "/start.sh" ]; then
  shift
fi

# Persistent state lives in /config. /app is read-only at runtime, so scratch space goes to /tmp.
mkdir -p /config/portainer
export TMPDIR=/tmp

# Portainer finds its UI assets relative to the working directory, so run from /app.
# UNVERIFIED: confirm the assets flag or default with /app/portainer --help on 2.45.4, and the flag names below.
cd /app
exec /app/portainer \
  --data /config/portainer \
  --bind 0.0.0.0:9000 \
  --bind-https 0.0.0.0:9443 \
  --tunnel-port 8000 \
  "$@"
