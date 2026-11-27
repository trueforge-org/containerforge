#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. Saves, config and downloads go to /config.
# UNVERIFIED: flags checked against OpenTTD's documented -D and -c options only; confirm with
# `openttd --help` in the built image. Graphics seeding is not implemented yet (UNVERIFIED need).
mkdir -p /config/saves

exec /app/openttd/openttd -D "0.0.0.0:3979" -c /config/openttd.cfg
