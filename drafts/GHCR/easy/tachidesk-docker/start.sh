#!/usr/bin/env bash
set -euo pipefail

# Data root: Suwayomi stores its state under user.home (layout as in the upstream image).
# UNVERIFIED: the server's data dir and bind address (upstream maps BIND_IP/BIND_PORT into
# server.conf in startup_script.sh; this draft does not write server.conf yet). Check on the first run.
export HOME=/config
mkdir -p /config/.local/share/Tachidesk /tmp/tachidesk

cd /app/tachidesk
exec java -Duser.home=/config -jar /app/tachidesk/Suwayomi-Server.jar
