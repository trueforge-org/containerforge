#!/usr/bin/env bash
set -euo pipefail

cd /app
exec python -u /app/exporter.py
