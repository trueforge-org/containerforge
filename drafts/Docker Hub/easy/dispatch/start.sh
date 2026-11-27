#!/usr/bin/env bash
set -euo pipefail

# Seed the config only when missing. Never overwrite user edits.
mkdir -p /config
[ -f /config/config.toml ] || cp /defaults/config.toml /config/config.toml

cd /config
# UNVERIFIED: --address and --port are the flags from commands/dispatch.go and are expected to win over config.toml.
exec /app/dispatch --dir=/config --address=0.0.0.0 --port=8080
