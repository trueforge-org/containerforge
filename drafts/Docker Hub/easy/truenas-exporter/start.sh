#!/usr/bin/env bash
set -euo pipefail

# The TrueNAS mapping file is user supplied (TrueCharts mounts it at /config/graphite_mapping.conf).
# It is not bundled: it is GPL-3.0 and this image is Apache-2.0 (see plan section 10).
MAPPING="${GRAPHITE_MAPPING_CONFIG:-/config/graphite_mapping.conf}"

# Listen on all interfaces so other containers can reach the ports.
# UNVERIFIED: flag names --web.listen-address and --graphite.listen-address (main.go was not readable at the tag).
args=(--web.listen-address=":9108" --graphite.listen-address=":9109")

if [[ -f "${MAPPING}" ]]; then
  args+=("--graphite.mapping-config=${MAPPING}")
else
  echo "No mapping file at ${MAPPING}, running without a mapping (metrics are converted automatically)."
fi

# EXPORTER_ARGS is split on purpose (for example --graphite.mapping-strict-match).
# shellcheck disable=SC2086
exec /usr/local/bin/graphite_exporter "${args[@]}" ${EXPORTER_ARGS:-}
