#!/usr/bin/env bash
# Usage: process-file.sh <media file>
# Settings come from the environment (set by start.sh). Options are split on ';' and whitespace only.
# They are never eval'd and never globbed.
set -euo pipefail

file="${1:?usage: process-file.sh <file>}"
script="${script:-mkvdts2ac3.sh}"
fmt="${output_format:-mkv}"

if [[ ! -f "${file}" ]]; then
  echo "not a regular file: ${file}" >&2
  exit 1
fi

# Split "-map 0;-c:v copy" into ("-map" "0" "-c:v" "copy") and store it in the array named by $1.
split_opts() {
  local -n _dst="$1"
  local raw="$2" item
  local -a words=()
  _dst=()
  while IFS= read -r item; do
    read -r -a words <<< "${item}"
    if (( ${#words[@]} )); then
      _dst+=("${words[@]}")
    fi
  done < <(printf '%s\n' "${raw}" | tr ';' '\n')
}

name="$(basename -- "${file}")"
base="${name%.*}"

# Keep a copy of the original in /copy when it is mounted (semantics UNVERIFIED).
if mountpoint -q /copy; then
  cp -p -- "${file}" /copy/
fi

case "${script}" in
  encode.sh)
    split_opts ff_params "${parameters:-}"
    /scripts/encode.sh "${file}" "/output/${base}.${fmt}" "${ff_params[@]}"
    ;;
  mkvdts2ac3.sh)
    split_opts mk_params "${mkvdts2ac3_params:-}"
    has_w=0
    for a in "${mk_params[@]}"; do
      [[ "${a}" == "-w" ]] && has_w=1
    done
    work=()
    if (( ! has_w )); then
      work=(-w /tmp/work)
    fi
    /app/mkvdts2ac3.sh "${work[@]}" "${mk_params[@]}" "${file}"
    ;;
  *)
    echo "unknown script: ${script}" >&2
    exit 1
    ;;
esac
