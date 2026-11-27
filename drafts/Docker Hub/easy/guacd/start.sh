#!/usr/bin/env bash
set -euo pipefail

# Same behaviour as the upstream entrypoint. guacd binds to localhost by default, so -b 0.0.0.0 is required
# for other containers (the Guacamole web client) to reach it.
if [ -n "${GUACD_LOG_LEVEL:-}" ]; then
  echo "WARNING: GUACD_LOG_LEVEL is deprecated, use LOG_LEVEL." >&2
fi

# Extra arguments from the container CMD are appended, so TLS (-C/-K) can be added the same way as upstream.
exec /usr/local/sbin/guacd -f -b 0.0.0.0 -l 4822 -L "${LOG_LEVEL:-${GUACD_LOG_LEVEL:-info}}" "$@"
