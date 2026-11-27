#!/bin/bash
set -euo pipefail

QBITRR_OVERRIDES_DATA_PATH="${QBITRR_OVERRIDES_DATA_PATH:-/config}"

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

# Persistent state lives in /config. qBitrr writes its own config on first start.
# UNVERIFIED: the config file name and first-run behaviour; confirm on the first local run.
mkdir -p "$QBITRR_OVERRIDES_DATA_PATH"
export QBITRR_OVERRIDES_DATA_PATH

# Scratch space goes to /tmp, since /app is read-only at runtime.
export TMPDIR=/tmp

# UNVERIFIED: the web UI must listen on 0.0.0.0:6969 for other containers. Check the default bind address in qBitrr's config.
exec python -m qBitrr.main "$@"
