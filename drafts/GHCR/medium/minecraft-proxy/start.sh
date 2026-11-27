#!/usr/bin/env bash

set -euo pipefail

# the image runs as apps: no chown and no privilege drop
export SKIP_CHOWN_DATA=true
export SKIP_PRIVILEGE_DROP=true

# keep helper caches and scratch on /tmp (read-only rootfs)
export HOME=/tmp
export TMPDIR=/tmp

export TYPE="${TYPE:-BUNGEECORD}"
export VELOCITY_VERSION="${VELOCITY_VERSION:-latest}"
export VELOCITY_BUILD_ID="${VELOCITY_BUILD_ID:-latest}"
export MEMORY="${MEMORY:-512m}"

case "${TYPE}" in
    BUNGEECORD|WATERFALL|VELOCITY|CUSTOM) ;;
    *)
        echo "TYPE must be one of BUNGEECORD, WATERFALL, VELOCITY or CUSTOM (got: ${TYPE})" >&2
        exit 1
        ;;
esac

# BUNGEE_HOME=/config (set in the Dockerfile) holds the proxy jar, config and plugins
mkdir -p /config

# UNVERIFIED: the upstream run-bungeecord.sh is not in the image yet (see the TODO in the Dockerfile); it is assumed to
# read the variables above and BUNGEE_HOME. Velocity 4.3.1 build 45 sha256 (Fill API, for review):
# 0844bcabdcdb4f5b875906fd4c3365bc1bb76918e42bc595ed88ad195258dd75. The helper downloads the jar at start.

exec /usr/bin/run-bungeecord.sh
