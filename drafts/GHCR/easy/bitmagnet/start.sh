#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/bitmagnet-cache
cd /config

export HOME=/config
export TMPDIR=/tmp

# Arguments follow the upstream compose example. The image ENTRYPOINT is the
# binary itself, so without "worker run" it would only print help. The
# dht_crawler key is optional. Database settings come from the environment only.
exec /app/bitmagnet/bitmagnet worker run \
  --keys=http_server \
  --keys=queue_server \
  --keys=dht_crawler
