#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

# ddns-go writes its config on first save from the web UI. Nothing is seeded here.
# The listen address and the update interval are the upstream CMD defaults.
exec /app/ddns-go -l :9876 -f 300 -c /config/.ddns_go_config.yaml
