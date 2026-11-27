#!/usr/bin/env bash
set -euo pipefail

# HOME=/config keeps HOOBS state (instance and plugins) in the volume. npm caches stay in /tmp (see Dockerfile).
mkdir -p /config /tmp/npm

# UNVERIFIED: subcommand and data-dir handling. Check `hoobs --help` on the first run.
exec hoobs start
