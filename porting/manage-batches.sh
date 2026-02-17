#!/usr/bin/env bash
set -euo pipefail

PORTING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POST_PROCESSED_DIR="${PORTING_DIR}/post-processed"
QUEUES_DIR="${PORTING_DIR}/queues"
ATTEMPTS_CSV="${PORTING_DIR}/BATCH_ATTEMPTS.csv"

usage() {
  cat <<'EOF'
Usage:
  ./manage-batches.sh refresh
  ./manage-batches.sh record <batch-name> <app1> [app2...]

Commands:
  refresh
    Rebuild pass/fail/unknown queue views from each app's latest
    "- Result: <...>" in NOT_WORKING_YET.md.

  record <batch-name> <apps...>
    Append batch attempt records and refresh queue views.
EOF
}

latest_result() {
  local app="$1"
  local note_file="${POST_PROCESSED_DIR}/${app}/NOT_WORKING_YET.md"
  if [[ ! -f "$note_file" ]]; then
    echo "UNKNOWN"
    return
  fi

  local result
  result="$(grep -E '^- Result: ' "$note_file" | tail -n1 | sed 's/^- Result: //')"
  if [[ -z "$result" ]]; then
    echo "UNKNOWN"
  else
    echo "$result"
  fi
}

ensure_attempt_header() {
  if [[ ! -f "$ATTEMPTS_CSV" ]]; then
    echo "timestamp,batch,app,result_at_record_time" > "$ATTEMPTS_CSV"
  fi
}

refresh_queues() {
  mkdir -p \
    "${QUEUES_DIR}/passing" \
    "${QUEUES_DIR}/failing" \
    "${QUEUES_DIR}/unknown" \
    "${QUEUES_DIR}/failing-unattempted"

  find "${QUEUES_DIR}/passing" "${QUEUES_DIR}/failing" "${QUEUES_DIR}/unknown" "${QUEUES_DIR}/failing-unattempted" -mindepth 1 -delete

  : > "${QUEUES_DIR}/passing.txt"
  : > "${QUEUES_DIR}/failing.txt"
  : > "${QUEUES_DIR}/unknown.txt"

  while IFS= read -r app_dir; do
    local_app="$(basename "$app_dir")"
    result="$(latest_result "$local_app")"
    case "$result" in
      PASS)
        ln -s "../../post-processed/${local_app}" "${QUEUES_DIR}/passing/${local_app}"
        echo "$local_app" >> "${QUEUES_DIR}/passing.txt"
        ;;
      FAIL)
        ln -s "../../post-processed/${local_app}" "${QUEUES_DIR}/failing/${local_app}"
        echo "$local_app" >> "${QUEUES_DIR}/failing.txt"
        ;;
      *)
        ln -s "../../post-processed/${local_app}" "${QUEUES_DIR}/unknown/${local_app}"
        echo "$local_app" >> "${QUEUES_DIR}/unknown.txt"
        ;;
    esac
  done < <(find "$POST_PROCESSED_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

  ensure_attempt_header

  declare -A attempted=()
  while IFS=, read -r _ _ app _; do
    [[ "$app" == "app" || -z "$app" ]] && continue
    attempted["$app"]=1
  done < "$ATTEMPTS_CSV"

  : > "${QUEUES_DIR}/failing-unattempted.txt"
  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    if [[ -z "${attempted[$app]+x}" ]]; then
      ln -s "../../post-processed/${app}" "${QUEUES_DIR}/failing-unattempted/${app}"
      echo "$app" >> "${QUEUES_DIR}/failing-unattempted.txt"
    fi
  done < "${QUEUES_DIR}/failing.txt"

  echo "Queues refreshed under: ${QUEUES_DIR}"
}

record_batch() {
  local batch="$1"
  shift
  if [[ $# -lt 1 ]]; then
    echo "record requires at least one app"
    usage
    exit 1
  fi

  ensure_attempt_header
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  for app in "$@"; do
    echo "${ts},${batch},${app},$(latest_result "$app")" >> "$ATTEMPTS_CSV"
  done
  refresh_queues
}

cmd="${1:-}"
case "$cmd" in
  refresh)
    refresh_queues
    ;;
  record)
    shift
    batch_name="${1:-}"
    if [[ -z "$batch_name" ]]; then
      echo "record requires a batch name"
      usage
      exit 1
    fi
    shift
    record_batch "$batch_name" "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
