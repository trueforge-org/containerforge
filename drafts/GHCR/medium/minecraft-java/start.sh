#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config

# The Mojang EULA must be accepted by the operator. The image does not accept it on the user's behalf.
if [[ "${EULA:-}" != "TRUE" ]]; then
    echo "The Minecraft EULA is not accepted. Set EULA=TRUE to start the server." >&2
    exit 1
fi
echo "eula=true" > /config/eula.txt

# Keep helper caches and temp files in /tmp (writable tmpfs at runtime).
export HOME=/tmp
export TMPDIR=/tmp

cd /config

# UNVERIFIED: the server jar download (TYPE / VERSION via mc-image-helper) is not ported in this draft.
# The upstream scripts were not read; see plan.md sections 7 and 10. Until then the jar must already be in /config.
if [[ ! -f /config/server.jar ]]; then
    echo "server.jar is missing from /config. The download step is not implemented in this draft." >&2
    exit 1
fi

exec java -Xms"${MEMORY}" -Xmx"${MEMORY}" -jar /config/server.jar nogui
