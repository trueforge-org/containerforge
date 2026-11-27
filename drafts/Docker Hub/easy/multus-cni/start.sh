#!/usr/bin/env bash
set -euo pipefail

# Sidecar use: the chart supplies the command; the ubuntu entrypoint passes it as arguments.
if [[ "$#" -gt 0 ]]; then
  exec "$@"
fi
exec /usr/local/bin/crane --help
