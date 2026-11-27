#!/usr/bin/env bash

mkdir -p /config
cd /config || exit 1

# Flags are passed straight through. The provider and sources come from the user or the chart.
exec /app/external-dns --metrics-address=":7979" "$@"
