#!/usr/bin/env bash
set -euo pipefail

# No config is seeded: spegel takes its settings from command-line flags (UNVERIFIED, flags not read yet).
# Arguments are passed through to the binary, so the container command selects the subcommand.
cd /app
exec /app/spegel "$@"
