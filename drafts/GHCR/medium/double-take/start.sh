#!/usr/bin/env bash
set -euo pipefail

# Replaces upstream entrypoint.sh. Upstream paths /.storage are remapped to /config/storage.
# Not carried over: HA add-on option import (HA_ADDON), SECRETS_PATH, and the
# nodemon config watch (UNVERIFIED impact: config changes then need a restart).

store="/config/storage"
mkdir -p "${store}/matches" "${store}/train" "${store}/latest" "${store}/config"

export CONFIG_PATH="${CONFIG_PATH:-${store}/config}"

cd /double-take || exit 1

# Upstream runs this check before the API starts. Its side effects are UNVERIFIED.
node -e 'require("./api/src/constants")()'

# CPU recognizer. Upstream adds -cnn only when CUDA is detected, which this image does not ship.
# UNVERIFIED: whether -d daemonises. It is backgrounded here either way.
/usr/local/bin/recognizer -port 8888 -models /opt/recognizer/models -storage "${store}" -d &

exec node api/server.js
