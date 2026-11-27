#!/usr/bin/env bash
set -euo pipefail

# Data lives in /config, the only writable persistent path. Created only when missing.
mkdir -p "${storageDataPath:-/config/data}"
export storageDataPath="${storageDataPath:-/config/data}"
export retentionPeriod="${retentionPeriod:-1M}"
# :8428 binds all interfaces, so other containers can reach the API.
export httpListenAddr="${httpListenAddr:-:8428}"

cd /config
# -envflag.enable lets any other flag be set by its environment name (dots become underscores).
# UNVERIFIED: VictoriaMetrics documents SIGINT for graceful stop, not SIGTERM. Check on shutdown.
exec /app/victoria-metrics-prod -envflag.enable "$@"
