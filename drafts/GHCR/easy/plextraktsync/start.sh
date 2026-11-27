#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export PTS_CONFIG_DIR=/config
export PTS_LOG_DIR=/config
export PTS_CACHE_DIR=/tmp/plextraktsync

mkdir -p /config "${PTS_CACHE_DIR}"
cd /config

# OPEN: run mode. The chart runs a CronJob, so this image runs one sync and exits by default.
# UNVERIFIED: the sync subcommand name and its flags; confirm with `plextraktsync --help`.
if [ "$#" -eq 0 ]; then
    set -- sync
fi

exec /app/venv/bin/plextraktsync "$@"
