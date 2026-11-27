#!/usr/bin/env bash
set -euo pipefail

umask "${UMASK:-022}"
export HOME=/config

mkdir -p /config/logs

# Seed the Comskip config only when missing, so user edits are kept.
if [[ ! -f /config/comskip.ini && -f /defaults/comskip.ini ]]; then
  cp /defaults/comskip.ini /config/comskip.ini
fi
export COMSKIP_INI=/config/comskip.ini
export TZ="${TZ:-Etc/UTC}"

# Optional user hook, run once at start when present.
if [[ -f /config/custom.sh ]]; then
  # UNVERIFIED: upstream custom.sh semantics; confirm against the chacawaca rootfs/ scripts.
  bash /config/custom.sh || echo "custom.sh exited with an error" >&2
fi

# Without a /watch mount (for example in the container test) stay idle instead of exiting.
if [[ ! -d /watch || ! -w /watch ]]; then
  echo "/watch is missing or not writable, idling until it is mounted" >&2
  trap 'exit 0' TERM INT
  while true; do sleep 3600 & wait $!; done
fi

echo "watching /watch for *.${SOURCE_EXT:-ts} files"
exec /scripts/watch.sh
