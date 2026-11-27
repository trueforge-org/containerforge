#!/usr/bin/env bash
set -euo pipefail

# gpodder keeps its state in GPODDER_HOME (/config) and downloads in GPODDER_DOWNLOAD_DIR (/downloads)
mkdir -p "${GPODDER_HOME:-/config}" "${GPODDER_DOWNLOAD_DIR:-/downloads}"

export XDG_CACHE_HOME=/tmp/cache
export HOME=/tmp

cd /tmp || exit 1
# UNVERIFIED: --no-gui is not confirmed as a headless run mode of gpodder 3.11.5; check gpodder --help on the first run
exec /app/venv/bin/gpodder --no-gui "$@"
