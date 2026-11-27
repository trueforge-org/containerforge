#!/usr/bin/env bash
set -euo pipefail

# All persistent state goes to /config. /app stays read-only.
mkdir -p /config/verysync

# Bind to all interfaces. The upstream entrypoint's VUID/gosu handling is not used: the image runs as apps.
# UNVERIFIED: whether the default sync folder lands under -home (plan.md section 7).
exec /app/verysync/verysync \
  -no-browser \
  -home /config/verysync \
  -gui-address ":${PORT:-8886}"
