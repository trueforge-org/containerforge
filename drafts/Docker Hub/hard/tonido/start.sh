#!/usr/bin/env bash
set -e

export HOME=/config
export LD_LIBRARY_PATH=/app/tonido

mkdir -p /config

exec /app/tonido/tonidoconsole /config
