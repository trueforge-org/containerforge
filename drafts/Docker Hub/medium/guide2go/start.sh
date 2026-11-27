#!/usr/bin/env bash
# guide2go has no scheduler of its own (the alturismo wrapper uses cron), so this
# loop runs `guide2go -config` every G2G_INTERVAL seconds.
set -u

CONFIG="${G2G_CONFIG:-/config/guide2go.yaml}"
INTERVAL="${G2G_INTERVAL:-86400}"
BIN=/app/guide2go
child=""
sleeper=""

forward_term() {
  [ -n "$child" ] && kill -TERM "$child" 2>/dev/null
  [ -n "$sleeper" ] && kill "$sleeper" 2>/dev/null
  exit 0
}
trap forward_term TERM INT

mkdir -p /config/images

# Seed the config only when it is missing or empty. Never overwrite user state.
if [ ! -s "$CONFIG" ]; then
  cp -n /defaults/guide2go.yaml "$CONFIG"
fi

while true; do
  # Skip the run until a Schedules Direct username is set in the config.
  if grep -Eq '^[[:space:]]*Username:[[:space:]]*[^[:space:]"]' "$CONFIG"; then
    "$BIN" -config "$CONFIG" &
    child=$!
    wait "$child"
    echo "guide2go: run finished with exit code $?"
    child=""
  else
    echo "guide2go: no Schedules Direct account configured; run: docker exec -it <container> guide2go -configure ${CONFIG}"
  fi

  sleep "$INTERVAL" &
  sleeper=$!
  wait "$sleeper"
  sleeper=""
done
