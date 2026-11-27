#!/usr/bin/env bash
set -euo pipefail

# Configuration comes from the env vars in settings.yaml (read by the binary itself), so no flags are passed here.
mkdir -p /config

cd /config
exec /app/kubelet-csr-approver
