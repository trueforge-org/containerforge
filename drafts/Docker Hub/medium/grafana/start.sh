#!/usr/bin/env bash

mkdir -p /config/data /config/log /config/plugins

cd /app/grafana || exit 1
# UNVERIFIED: --packaging=docker flag is not used by this .deb build unless the binary needs it.
exec /app/grafana/bin/grafana server \
  --homepath=/app/grafana \
  --config=/etc/grafana/grafana.ini
