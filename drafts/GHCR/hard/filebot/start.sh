#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/logs
export HOME=/config

interval="${AMC_INTERVAL:-1800}"
action="${AMC_ACTION:-test}"
conflict="${AMC_CONFLICT:-auto}"
lang="${AMC_LANG:-English}"
input="${AMC_INPUT_DIR:-/watch}"
output="${AMC_OUTPUT_DIR:-/output}"

cd /app/filebot

# UNVERIFIED: the fn:amc options below are not confirmed against the FileBot docs.
# Run ./filebot.sh -script fn:amc --help in the build step and fix the options before shipping.
# The loop keeps AMC running on the interval, so this foreground loop does not use exec.
while true; do
    ./filebot.sh -script fn:amc \
        --output "${output}" \
        --action "${action}" \
        --conflict "${conflict}" \
        --lang "${lang}" \
        "${input}" 2>&1 | tee -a /config/logs/amc.log || echo "AMC run failed, see /config/logs/amc.log"
    sleep "${interval}"
done
