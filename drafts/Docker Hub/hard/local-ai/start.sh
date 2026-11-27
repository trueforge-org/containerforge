#!/usr/bin/env bash
set -euo pipefail

# Everything LocalAI writes goes under /config (persistent) or /tmp (upload scratch). Nothing is written to /app.
mkdir -p \
  /config/models \
  /config/backends \
  /config/data \
  /config/configuration \
  /config/generated \
  /config/downloading \
  /tmp/upload

# The bind address comes from LOCALAI_ADDRESS, so no --address flag is passed here.
export HOME=/config
cd /config
exec /app/local-ai run
