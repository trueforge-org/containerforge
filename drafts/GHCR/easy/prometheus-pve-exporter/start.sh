#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Seed the template only when pve.yml is missing or empty. The placeholder token must be replaced.
if [ ! -s /config/pve.yml ]; then
    cp /defaults/pve.yml /config/pve.yml
fi

exec /app/venv/bin/pve_exporter --config.file=/config/pve.yml "--web.listen-address=[::]:9221" "$@"
