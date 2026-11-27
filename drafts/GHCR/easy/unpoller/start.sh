#!/usr/bin/env bash
set -euo pipefail

# Seed the example config into /config only when it is missing or empty. An
# existing user config is never overwritten.
mkdir -p /config
if [ ! -s /config/up.conf ]; then
  cp /etc/unpoller/up.conf /config/up.conf
fi

# UNVERIFIED: the --config flag name. Confirm with "unpoller --help" during the build.
exec /app/unpoller/unpoller --config /config/up.conf
