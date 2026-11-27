#!/usr/bin/env bash
set -euo pipefail

# Persistent state only. Nothing is written to /app.
mkdir -p /config/rtorrent/session /config/flood

# UNVERIFIED: rtorrent needs an SCGI or XML-RPC endpoint that flood can reach. The rc config is not written yet and belongs in defaults/.
rtorrent -n -s /config/rtorrent/session &

# UNVERIFIED: flood CLI flags. The host and port are taken from the upstream image.
exec /app/flood --host 0.0.0.0 --port 3000 --rundir /config/flood "$@"
