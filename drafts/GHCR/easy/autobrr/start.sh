#!/usr/bin/env bash
set -euo pipefail

# Listen address and port come from AUTOBRR__HOST and AUTOBRR__PORT (set in the Dockerfile).
# autobrr keeps its config and database under /config (XDG_CONFIG_HOME, XDG_DATA_HOME).
exec /app/autobrr --config /config
