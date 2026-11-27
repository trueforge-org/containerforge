#!/usr/bin/env bash
set -euo pipefail

# Hand off to the sidecar so signals reach the binary. The sidecar writes nothing under /app.
# UNVERIFIED: its behaviour without a Kubernetes API is not confirmed; see the plan's risks section.
exec /app/gatus-sidecar "$@"
