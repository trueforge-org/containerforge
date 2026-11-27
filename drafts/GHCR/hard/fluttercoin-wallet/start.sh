#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

mkdir -p /config/data

# UNVERIFIED for this fork: -datadir, -printtoconsole and -bind are Bitcoin-style guesses.
# -bind=0.0.0.0 is the flag the TrueCharts chart passes (EXTRA_PARAMS). Confirm with fluttercoind -help.
exec /app/fluttercoin/bin/fluttercoind \
  -datadir=/config/data \
  -printtoconsole \
  -bind=0.0.0.0
