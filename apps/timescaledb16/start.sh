#!/bin/bash
# CloudNativePG replaces this command. It allows the image to start on its own, for the container tests.
set -euo pipefail

PGDATA="${PGDATA:-/config/data}"

if [[ ! -s "${PGDATA}/PG_VERSION" ]]; then
  initdb --pgdata="${PGDATA}" --username=postgres --auth=trust --encoding=UTF8 --locale=C
fi

echo "Started without a password, so only listening on localhost. Use this image with CloudNativePG."
exec postgres -D "${PGDATA}" \
  -c listen_addresses=127.0.0.1 \
  -c unix_socket_directories=/tmp \
  -c shared_preload_libraries=timescaledb \
  -c timescaledb.telemetry_level=off
