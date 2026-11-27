#!/usr/bin/env bash
set -euo pipefail

IP="${IP:-::}"
PORT="${PORT:-1688}"

args=(-u /app/py-kms/pykms_Server.py "${IP}" "${PORT}")

# Pass an option only when its value is not empty, as docker/start.py does.
add_opt() {
  local flag="$1"
  local value="$2"
  if [[ -n "${value}" ]]; then
    args+=("${flag}" "${value}")
  fi
}

add_opt -l "${LCID:-1033}"
add_opt -c "${CLIENT_COUNT:-26}"
add_opt -a "${ACTIVATION_INTERVAL:-120}"
add_opt -r "${RENEWAL_INTERVAL:-10080}"
add_opt -w "${HWID:-RANDOM}"
add_opt -V "${LOGLEVEL:-INFO}"
add_opt -F "${LOGFILE:-STDOUT}"
add_opt -S "${LOGSIZE:-}"
add_opt -e "${EPID:-}"

# UNVERIFIED: start.py's DUALSTACK and entrypoint.py behaviour are not reproduced; single address only.
cd /app/py-kms
exec /app/venv/bin/python "${args[@]}"
