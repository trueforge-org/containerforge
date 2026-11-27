#!/usr/bin/env bash
# Usage: encode.sh <input> <output> [ffmpeg output options...]
# Called by process-file.sh. -n refuses to overwrite an existing output, so a repeated run fails loudly.
set -euo pipefail

in="$1"
out="$2"
shift 2

exec ffmpeg -nostdin -hide_banner -loglevel error -n -i "${in}" "$@" "${out}"
