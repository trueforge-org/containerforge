#!/usr/bin/env bash
# Initial draft. UNVERIFIED: the env names the binary reads, and whether it needs ADMIN_TOKEN at all (plan sections 6 and 7).

mkdir -p /config/data
cd /config || exit 1

# Generate the admin token once and keep it in /config. Never reuse the chart placeholder.
umask 077
if [ ! -s /config/admin.env ]; then
  echo "ADMIN_TOKEN=$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 40)" > /config/admin.env
fi
set -a
. /config/admin.env
set +a

export INSTANCE_LISTEN="${INSTANCE_LISTEN:-0.0.0.0}"

exec /app/gravity/gravity server
