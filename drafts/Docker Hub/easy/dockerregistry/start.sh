#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data
[ -f /config/config.yml ] || cp /defaults/config.yml /config/config.yml

exec /app/registry serve /config/config.yml
