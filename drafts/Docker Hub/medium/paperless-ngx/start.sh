#!/usr/bin/env bash
set -euo pipefail

# Stateless sidecar: nothing to seed. Java temp files go to /tmp (read-only rootfs).
# Binds all interfaces, as the upstream ENTRYPOINT does (-h 0.0.0.0). The port defaults to 9998.
exec java \
  -Djava.io.tmpdir=/tmp \
  -cp "/app/bin/tika-server.jar:/tika-extras/*" \
  org.apache.tika.server.core.TikaServerCli \
  -h 0.0.0.0 \
  "$@"
