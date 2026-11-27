#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Caches are kept there as well (plan.md section 7, open decision).
mkdir -p /config/cache /config/playlists /config/podcasts

export GONIC_LISTEN_ADDR="${GONIC_LISTEN_ADDR:-0.0.0.0:4747}"
export GONIC_DB_PATH="${GONIC_DB_PATH:-/config/gonic.db}"
export GONIC_MUSIC_PATH="${GONIC_MUSIC_PATH:-/music}"
export GONIC_CACHE_PATH="${GONIC_CACHE_PATH:-/config/cache}"
export GONIC_PODCAST_PATH="${GONIC_PODCAST_PATH:-/config/podcasts}"
export GONIC_PLAYLISTS_PATH="${GONIC_PLAYLISTS_PATH:-/config/playlists}"

# UNVERIFIED: whether gonic starts with an empty or missing /music path (the test mounts nothing).
exec /app/gonic/gonic
