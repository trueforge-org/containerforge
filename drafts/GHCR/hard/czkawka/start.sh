#!/bin/bash
set -e

# CLI-only image: no server runs. Arguments are passed to czkawka_cli,
# for example: docker run ... czkawka:12.0.2 dup -d /storage
# Keep caches in /tmp (XDG_CACHE_HOME), never in /config or /app.
mkdir -p /config

if [ "$#" -eq 0 ]; then
  set -- --help
fi

exec /app/czkawka/czkawka_cli "$@"
