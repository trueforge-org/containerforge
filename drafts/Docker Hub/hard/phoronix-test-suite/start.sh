#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config (test profiles, results, download cache). Scratch goes to /tmp.
mkdir -p "${PTS_USER_PATH_OVERRIDE:-/config/pts}" "${PTS_DOWNLOAD_CACHE_OVERRIDE:-/config/download-cache}" /tmp/pts
export TMPDIR=/tmp

# Upstream defaults to "shell". Without a TTY that exits at once, so keep the container alive for `docker exec`.
if [ "$#" -eq 0 ] && [ ! -t 0 ]; then
  exec sleep infinity
fi

exec /app/phoronix-test-suite "${@:-shell}"
