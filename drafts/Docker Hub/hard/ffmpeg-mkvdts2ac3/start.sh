#!/usr/bin/env bash
# Watches /watch and processes each new media file with /scripts/process-file.sh.
# This is our own implementation. The Docker Hub image's scripts are not public, so the exact semantics are UNVERIFIED.
set -euo pipefail

mkdir -p /config /watch /output /copy /tmp/work

# process-file.sh reads these from the environment. Defaults match settings.yaml.
export script="${script:-mkvdts2ac3.sh}"
export output_format="${output_format:-mkv}"
export parameters="${parameters:-}"
export mkvdts2ac3_params="${mkvdts2ac3_params:-}"

case "${script}" in
  encode.sh|mkvdts2ac3.sh) ;;
  *)
    echo "Unknown script '${script}', use encode.sh or mkvdts2ac3.sh" >&2
    exit 1
    ;;
esac

process() {
  /scripts/process-file.sh "$1" < /dev/null || echo "failed: $1" >&2
}

# Process files that are already waiting, so a restart picks up where it stopped.
find /watch -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' \) -print0 |
  while IFS= read -r -d '' f; do process "$f"; done

# The watcher is a pipeline, so it cannot be exec'd. Docker's stop signal may need the grace period to finish it.
inotifywait -m -r -e close_write -e moved_to --format '%w%f' /watch |
  while IFS= read -r f; do process "$f"; done
