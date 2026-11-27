#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-34197}"
RCON_PORT="${RCON_PORT:-27015}"
SAVE_NAME="${SAVE_NAME:-_autosave1}"
LOAD_LATEST_SAVE="${LOAD_LATEST_SAVE:-true}"
GENERATE_NEW_SAVE="${GENERATE_NEW_SAVE:-false}"
PRESET="${PRESET:-}"
BIND="${BIND:-}"

CONFIG=/config/config
SAVES=/config/saves
MODS=/config/mods
mkdir -p "$CONFIG" "$SAVES" "$MODS" /config/scenarios /config/script-output

[ -f /config/config.ini ] || cp /defaults/config.ini /config/config.ini

# RCON password generated once, kept 0600 in /config
# UNVERIFIED: no password-file flag was found, so it is passed on the command line (inside the container only).
if [ ! -f "$CONFIG/rconpw" ]; then
  ( umask 077; uuidgen | tr -d '-' > "$CONFIG/rconpw" )
fi

# UNVERIFIED: default JSON files are taken from the archive's data/ directory
for f in server-settings map-gen-settings map-settings; do
  [ -f "$CONFIG/$f.json" ] || cp "/app/data/$f.example.json" "$CONFIG/$f.json"
done
rm -f "$SAVES"/*.tmp.zip

SAVE_FILE="$SAVES/${SAVE_NAME%.zip}.zip"
if [ -z "$(find "$SAVES" -name '*.zip' -print -quit)" ]; then
  GENERATE_NEW_SAVE=true
fi
# Never overwrite an existing save file
if [ "$GENERATE_NEW_SAVE" = "true" ] && [ ! -f "$SAVE_FILE" ]; then
  CREATE=(--config /config/config.ini --create "$SAVE_FILE"
          --map-gen-settings "$CONFIG/map-gen-settings.json"
          --map-settings "$CONFIG/map-settings.json")
  if [ -n "$PRESET" ]; then CREATE+=(--preset "$PRESET"); fi
  /app/bin/x64/factorio "${CREATE[@]}"
fi

# UNVERIFIED: ban/whitelist/admin/id file names, and that an empty whitelist with --use-server-whitelist does not lock everyone out.
FLAGS=(--config /config/config.ini
  --server-settings "$CONFIG/server-settings.json"
  --server-banlist "$CONFIG/server-banlist.json"
  --server-whitelist "$CONFIG/server-whitelist.json"
  --use-server-whitelist
  --server-adminlist "$CONFIG/server-adminlist.json"
  --server-id "$CONFIG/server-id.json"
  --mod-directory "$MODS"
  --port "$PORT"
  --rcon-port "$RCON_PORT"
  --rcon-password "$(cat "$CONFIG/rconpw")")
if [ -n "$BIND" ]; then FLAGS+=(--bind "$BIND"); fi

if [ "$LOAD_LATEST_SAVE" = "true" ]; then
  FLAGS+=(--start-server-load-latest)
else
  FLAGS+=(--start-server "$SAVE_FILE")
fi

exec /app/bin/x64/factorio "${FLAGS[@]}" "$@"
