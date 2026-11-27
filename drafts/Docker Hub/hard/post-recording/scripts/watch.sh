#!/usr/bin/env bash
set -euo pipefail

WATCH_DIR=/watch
SOURCE_EXT="${SOURCE_EXT:-ts}"
SOURCE_STABLE_TIME="${SOURCE_STABLE_TIME:-10}"
SOURCE_MIN_DURATION="${SOURCE_MIN_DURATION:-10}"

# Stop the whole process group on TERM or INT.
trap 'kill 0' TERM INT

# A file is ready when its size stops changing for SOURCE_STABLE_TIME seconds.
is_stable() {
  local f="$1" s1 s2
  s1=$(stat -c %s "$f") || return 1
  sleep "$SOURCE_STABLE_TIME"
  s2=$(stat -c %s "$f") || return 1
  [[ "$s1" == "$s2" ]]
}

process() {
  local f="$1" dur
  [[ "$f" == *."$SOURCE_EXT" ]] || return 0
  [[ -f "$f" ]] || return 0
  if ! is_stable "$f"; then
    echo "skipping $f: still being written" >&2
    return 0
  fi
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null | cut -d. -f1 || true)
  [[ "$dur" =~ ^[0-9]+$ ]] || dur=0
  if (( dur < SOURCE_MIN_DURATION )); then
    echo "skipping $f: shorter than ${SOURCE_MIN_DURATION}s" >&2
    return 0
  fi
  echo "converting $f"
  /scripts/convert.sh "$f" || echo "conversion failed: $f" >&2
}

# One sweep of existing files at start, then follow new ones.
find "$WATCH_DIR" -type f -name "*.${SOURCE_EXT}" -print0 | while IFS= read -r -d '' f; do
  process "$f"
done

inotifywait -m -r -q -e close_write -e moved_to --format '%w%f' "$WATCH_DIR" | while IFS= read -r f; do
  process "$f"
done
