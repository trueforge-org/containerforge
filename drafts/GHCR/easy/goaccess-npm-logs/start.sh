#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export TMPDIR=/tmp

REPORT_DIR="/config/reports"
mkdir -p "${REPORT_DIR}" /tmp/goaccess

LOG_DIR="${GOACCESS_LOG_DIR:-/opt/log}"
shopt -s nullglob
logs=( "${LOG_DIR}"/proxy-host-*_access.log )
shopt -u nullglob

# No logs yet (or no mount, as in the test run): read an empty file so GoAccess keeps running.
if [ "${#logs[@]}" -eq 0 ]; then
    : > /tmp/goaccess/empty.log
    logs=( /tmp/goaccess/empty.log )
fi

# UNVERIFIED: --date-format, --time-format, --addr and --port flag names; confirm with "goaccess --help" in the build test.
exec goaccess "${logs[@]}" \
    --log-format='[%d:%t %^] %^ %^ %s - %m %^ %v "%U" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] "%u" "%R"' \
    --date-format=%d/%b/%Y \
    --time-format=%H:%M:%S \
    --real-time-html \
    --addr=0.0.0.0 \
    --port=7880 \
    -o "${REPORT_DIR}/report.html"
