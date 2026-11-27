#!/usr/bin/env bash
set -euo pipefail

# Usage: convert.sh <source file>
src="$1"
dir="$(dirname "$src")"
base="$(basename "$src")"
stem="${base%.*}"
fmt="${CONVERSION_FORMAT:-mp4}"
work="$(mktemp -d /tmp/post-recording.XXXXXX)"
trap 'rm -rf "$work"' EXIT

# Remux without re-encoding. UNVERIFIED: the upstream ffmpeg command line.
ffmpeg -nostdin -hide_banner -loglevel error -y -i "$src" -map 0 -c copy "$work/$stem.$fmt"

# Extract subtitles to .srt when SUBTITLES=0. UNVERIFIED: ccextractor flags.
if [[ "${SUBTITLES:-0}" == "0" ]]; then
  ccextractor -out=srt -o "$work/$stem.srt" "$src" || echo "no subtitles extracted from $src" >&2
fi

# Chapters (comchap) or ad removal (comcut). UNVERIFIED: the exact CLI of comchap/comcut.
case "${POST_PROCESS:-comchap}" in
  comchap|comcut)
    "/usr/local/bin/${POST_PROCESS:-comchap}" "$work/$stem.$fmt" || echo "${POST_PROCESS} failed for $src" >&2
    ;;
  *)
    echo "unknown POST_PROCESS: ${POST_PROCESS}" >&2
    ;;
esac

mv -f "$work/$stem.$fmt" "$dir/$stem.$fmt"
if [[ -f "$work/$stem.srt" ]]; then
  mv -f "$work/$stem.srt" "$dir/$stem.srt"
fi

# DELETE_TS: 0 delete the source, 1 keep it, 2 move it to /backup.
case "${DELETE_TS:-1}" in
  0) rm -f "$src" ;;
  2)
    mkdir -p /backup
    mv -f "$src" "/backup/$base"
    ;;
  *) ;;
esac
