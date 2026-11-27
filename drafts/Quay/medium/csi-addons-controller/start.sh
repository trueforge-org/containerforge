#!/usr/bin/env bash
set -euo pipefail

export HOME=/tmp
cd /tmp

# Pass through the chart's manager flags. The manager keeps no state on disk.
exec /app/csi-addons-manager "$@"
