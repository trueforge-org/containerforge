#!/usr/bin/env bash
set -euo pipefail

# GPU_PLUGIN_ARGS is split on whitespace on purpose (for example "-shared-dev-num 2").
# shellcheck disable=SC2086
# UNVERIFIED: whether the plugin stays up when /var/lib/kubelet/device-plugins is missing (plain docker run).
exec /app/intel_gpu_device_plugin ${GPU_PLUGIN_ARGS:-}
