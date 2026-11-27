#!/usr/bin/env bash
set -euo pipefail

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/.cache}"
mkdir -p "${XDG_CACHE_HOME}" /config

GLANCES_OPT="${GLANCES_OPT:--w}"

ARGS=()
# Optional user config, never created or overwritten by this script.
if [ -f /config/glances.conf ]; then
  ARGS+=(-C /config/glances.conf)
fi

# GLANCES_OPT is intentionally word-split, as the upstream image does.
# shellcheck disable=SC2086
exec /app/venv/bin/glances "${ARGS[@]}" ${GLANCES_OPT} "$@"
