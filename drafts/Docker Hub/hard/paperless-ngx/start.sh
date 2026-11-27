#!/usr/bin/env bash
set -euo pipefail

# Gotenberg reads its own env vars; nothing is seeded and nothing is written outside /tmp.
export HOME=/tmp TMPDIR=/tmp
mkdir -p /tmp/gotenberg

exec gotenberg "$@"
