#!/bin/sh
export OUTPUT_DIR="${OUTPUT_DIR:-/tmp/balfolk}"
mkdir -p "$OUTPUT_DIR"

python3 /app/balfolk_ical.py && crond -f -L /dev/stdout &
exec python3 -m http.server 8000 --directory "$OUTPUT_DIR"
