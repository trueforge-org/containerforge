#!/usr/bin/env bash
set -euo pipefail

export DATABASE="${DATABASE:-/config/.dizquetv}"
export PORT="${PORT:-8000}"

mkdir -p "${DATABASE}"

# The app creates its own subdirectories (images, channels, filler, cache) on first run.
# It listens on all interfaces; confirm from outside the container during the run test.
cd /app/dizquetv
exec node index.js
