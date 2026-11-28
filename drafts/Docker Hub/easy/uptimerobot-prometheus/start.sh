#!/usr/bin/env bash
set -euo pipefail

export UPTIMEROBOT_SERVER_NAME="${UPTIMEROBOT_SERVER_NAME:-0.0.0.0}"
export UPTIMEROBOT_SERVER_PORT="${UPTIMEROBOT_SERVER_PORT:-9705}"

if [[ -z "${UPTIMEROBOT_API_KEY:-}" ]]; then
  echo "WARNING: UPTIMEROBOT_API_KEY is not set. Metrics will not be available until a read-only API key is configured."
  # UNVERIFIED: upstream exits with status 2 when no key is given. A placeholder keeps the
  # container running so the probe and the empty-config start work. Confirm during the run test.
  export UPTIMEROBOT_API_KEY="not-configured"
fi

cd /app/exporter
exec /app/venv/bin/python /app/exporter/exporter.py
