#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives under /config. Nothing is seeded: the server creates its own database on first start.
mkdir -p /config /config/metadata

cd /app/audiobookshelf
# UNVERIFIED: the server must listen on all interfaces at the tag (check the listen call). Add HOST=0.0.0.0 only if the server reads it.
exec node dist-server/index.js
