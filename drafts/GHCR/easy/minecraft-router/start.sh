#!/usr/bin/env bash
set -euo pipefail

# Routing is set by mc-router flags or the env names it reads itself (for example MAPPING and DEFAULT).
# UNVERIFIED: the default bind address and the exact flag names for the listen port; confirm in a run.
cd /app
exec /app/mc-router "$@"
