#!/usr/bin/env bash
# Any FLEXO_* variable switches flexo from /etc/flexo/flexo.toml to env-only config, and flexo then unwraps
# every required value. So all of them are exported here with defaults from upstream flexo.toml
# (the [mirrors_auto] values come from the planning notes).
# UNVERIFIED: whether string values need TOML quotes in env mode. Check with a real start.
set -euo pipefail

: "${FLEXO_CACHE_DIRECTORY:=/config/cache/pkg}"
: "${FLEXO_MIRRORLIST_FALLBACK_FILE:=/config/cache/state/mirrorlist}"
: "${FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE:=/config/cache/state/latency_test_results.json}"
: "${FLEXO_PORT:=7878}"
: "${FLEXO_LISTEN_IP_ADDRESS:=0.0.0.0}"
: "${FLEXO_MIRROR_SELECTION_METHOD:=auto}"
: "${FLEXO_MIRRORS_PREDEFINED:=[]}"
: "${FLEXO_NUM_VERSIONS_RETAIN:=3}"
: "${FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES:=[]}"
: "${FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED:=true}"
: "${FLEXO_MIRRORS_AUTO_IPV4:=true}"
: "${FLEXO_MIRRORS_AUTO_IPV6:=false}"
: "${FLEXO_MIRRORS_AUTO_MAX_SCORE:=2.5}"
: "${FLEXO_MIRRORS_AUTO_NUM_MIRRORS:=8}"
: "${FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT:=sort}"
: "${FLEXO_MIRRORS_AUTO_TIMEOUT:=350}"

export FLEXO_CACHE_DIRECTORY FLEXO_MIRRORLIST_FALLBACK_FILE FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE \
  FLEXO_PORT FLEXO_LISTEN_IP_ADDRESS FLEXO_MIRROR_SELECTION_METHOD FLEXO_MIRRORS_PREDEFINED \
  FLEXO_NUM_VERSIONS_RETAIN FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED \
  FLEXO_MIRRORS_AUTO_IPV4 FLEXO_MIRRORS_AUTO_IPV6 FLEXO_MIRRORS_AUTO_MAX_SCORE \
  FLEXO_MIRRORS_AUTO_NUM_MIRRORS FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT FLEXO_MIRRORS_AUTO_TIMEOUT

# Only mkdir runs here, so restarts are safe. Nothing is written to /app.
# /tmp/flexo/uncacheable is hard-coded in flexo and lives on the tmpfs.
mkdir -p "${FLEXO_CACHE_DIRECTORY}" \
  "$(dirname "${FLEXO_MIRRORLIST_FALLBACK_FILE}")" \
  "$(dirname "${FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE}")" \
  /tmp/flexo/uncacheable

exec /usr/bin/flexo
