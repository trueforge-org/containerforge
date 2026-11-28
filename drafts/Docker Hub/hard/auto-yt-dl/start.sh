#!/bin/bash
set -euo pipefail

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

# The app reads and writes data/ and Downloads/ relative to the working directory.
mkdir -p /config/data /config/Downloads
cd /config

# Flask GUI (0.0.0.0:5000, set in app.py) and the 15 minute download loop.
python3 /app/app.py &
web=$!
python3 /app/main.py &
loop=$!

trap 'kill "$web" "$loop" 2>/dev/null || true' TERM INT

# Stop the container if either process dies.
status=0
wait -n "$web" "$loop" || status=$?
kill "$web" "$loop" 2>/dev/null || true
wait || true
exit "$status"
