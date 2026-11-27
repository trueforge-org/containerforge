#!/usr/bin/env bash

set -euo pipefail

export SRV_NAME="${SRV_NAME:-Docker NWN:EE}"
export GAME_PORT="${GAME_PORT:-5121}"
export MAX_CLIENTS="${MAX_CLIENTS:-4}"

mkdir -p "${SERVER_DIR:-/config/nwnee}"

# BLOCKER: the server binary is not packaged yet (plan section 10). Fail loudly rather than run a placeholder.
echo "neverwinternights-ee: server binary not packaged in this draft" >&2
exit 1
