#!/usr/bin/env bash
set -euo pipefail

PORTING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUEUES_DIR="${PORTING_DIR}/queues"
ATTEMPTS_CSV="${PORTING_DIR}/BATCH_ATTEMPTS.csv"
PASSING_DIR="${QUEUES_DIR}/passing"
FAILING_DIR="${QUEUES_DIR}/failing"
UNKNOWN_DIR="${QUEUES_DIR}/unknown"
LEGACY_POST_PROCESSED_DIR="${PORTING_DIR}/post-processed"

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
  local note_file=""
  for dir in "$PASSING_DIR" "$FAILING_DIR" "$UNKNOWN_DIR" "$LEGACY_POST_PROCESSED_DIR"; do
    if [[ -f "${dir}/${app}/NOT_WORKING_YET.md" ]]; then
      note_file="${dir}/${app}/NOT_WORKING_YET.md"
      break
    fi
  done
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

app_dir_path() {
  local app="$1"
  for dir in "$PASSING_DIR" "$FAILING_DIR" "$UNKNOWN_DIR" "$LEGACY_POST_PROCESSED_DIR"; do
    if [[ -d "${dir}/${app}" ]]; then
      echo "${dir}/${app}"
      return
    fi
  done
  return 1
}

list_apps() {
  find "$PASSING_DIR" "$FAILING_DIR" "$UNKNOWN_DIR" "$LEGACY_POST_PROCESSED_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | \
    xargs -r -n1 basename | sort -u
}

ensure_attempt_header() {
  if [[ ! -f "$ATTEMPTS_CSV" ]]; then
    echo "timestamp,batch,app,result_at_record_time" > "$ATTEMPTS_CSV"
  fi
}

refresh_queues() {
  mkdir -p \
    "${PASSING_DIR}" \
    "${FAILING_DIR}" \
    "${UNKNOWN_DIR}" \
    "${QUEUES_DIR}/failing-unattempted"

  find "${QUEUES_DIR}/failing-unattempted" -mindepth 1 -delete

  : > "${QUEUES_DIR}/passing.txt"
  : > "${QUEUES_DIR}/failing.txt"
  : > "${QUEUES_DIR}/unknown.txt"

  while IFS= read -r local_app; do
    result="$(latest_result "$local_app")"
    current_dir="$(app_dir_path "$local_app" || true)"
    case "$result" in
      PASS)
        target_dir="${PASSING_DIR}/${local_app}"
        if [[ -n "$current_dir" && "$current_dir" != "$target_dir" ]]; then
          [[ -e "$target_dir" ]] && rm -rf "$target_dir"
          mv "$current_dir" "$target_dir"
        fi
        echo "$local_app" >> "${QUEUES_DIR}/passing.txt"
        ;;
      FAIL)
        target_dir="${FAILING_DIR}/${local_app}"
        if [[ -n "$current_dir" && "$current_dir" != "$target_dir" ]]; then
          [[ -e "$target_dir" ]] && rm -rf "$target_dir"
          mv "$current_dir" "$target_dir"
        fi
        echo "$local_app" >> "${QUEUES_DIR}/failing.txt"
        ;;
      *)
        target_dir="${UNKNOWN_DIR}/${local_app}"
        if [[ -n "$current_dir" && "$current_dir" != "$target_dir" ]]; then
          [[ -e "$target_dir" ]] && rm -rf "$target_dir"
          mv "$current_dir" "$target_dir"
        fi
        echo "$local_app" >> "${QUEUES_DIR}/unknown.txt"
        ;;
    esac
  done < <(list_apps)

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
      ln -s "../failing/${app}" "${QUEUES_DIR}/failing-unattempted/${app}"
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
