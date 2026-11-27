#!/usr/bin/env bash
set -euo pipefail

# Stateless exporter: nothing to seed and nothing written under /app or /config.
LISTEN_ADDRESS="${WEB_LISTEN_ADDRESS:-0.0.0.0:9835}"
COLLECT_BACKEND="${COLLECT_BACKEND:-nvml}"

# UNVERIFIED: flag names are taken from the TrueCharts chart. The default bind address is not confirmed.
exec /app/nvidia_gpu_exporter \
  --web.listen-address "${LISTEN_ADDRESS}" \
  --collect.backend "${COLLECT_BACKEND}" \
  "$@"
