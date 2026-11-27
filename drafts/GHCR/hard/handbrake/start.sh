#!/usr/bin/env bash

# Headless automated conversion: converts new video files from /storage into /output.
# UNVERIFIED: the upstream GUI and its AUTOMATED_CONVERSION stability checks are not ported;
# this loop skips the stable-time and minimum-duration checks.
STORAGE_DIR=/storage
OUTPUT_DIR="${AUTOMATED_CONVERSION_OUTPUT_DIR:-/output}"
PRESET="${AUTOMATED_CONVERSION_PRESET:-General/Very Fast 1080p30}"
FORMAT="${AUTOMATED_CONVERSION_FORMAT:-mp4}"
INTERVAL="${AUTOMATED_CONVERSION_CHECK_INTERVAL:-5}"

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
mkdir -p "${HOME}" "${XDG_CACHE_HOME}" "${OUTPUT_DIR}"

while true; do
  if [[ -d "${STORAGE_DIR}" ]]; then
    while IFS= read -r -d '' src; do
      rel="${src#"${STORAGE_DIR}"/}"
      out="${OUTPUT_DIR}/${rel%.*}.${FORMAT}"
      # never overwrite an existing output, so a restart does not redo finished work
      [[ -e "${out}" ]] && continue
      mkdir -p "$(dirname "${out}")"
      tmp="/tmp/convert-$$.${FORMAT}"
      echo "converting ${src} -> ${out}"
      if HandBrakeCLI -i "${src}" -o "${tmp}" -Z "${PRESET}" </dev/null; then
        mv "${tmp}" "${out}"
      else
        echo "conversion failed: ${src}" >&2
        rm -f "${tmp}"
      fi
    done < <(find "${STORAGE_DIR}" -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mov' \) -print0)
  fi
  sleep "${INTERVAL}"
done
