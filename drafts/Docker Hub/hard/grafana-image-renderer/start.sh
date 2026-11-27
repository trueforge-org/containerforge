#!/usr/bin/env bash

set -euo pipefail

export HOME=/tmp
export XDG_CONFIG_HOME=/tmp/.config
export XDG_CACHE_HOME=/tmp/.cache
mkdir -p "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}"

export SERVER_ADDR="${SERVER_ADDR:-:8081}"
# --no-sandbox is needed without privileges. It is a security trade-off, to be noted in the PR.
export BROWSER_FLAGS="${BROWSER_FLAGS:-"--no-sandbox --disable-dev-shm-usage"}"
export CHROME_BIN="${CHROME_BIN:-/usr/local/bin/chromium}"

if [[ "${AUTH_TOKEN:--}" == "-" ]]; then
    echo "AUTH_TOKEN is not set (default '-'): any client can request renders. Set AUTH_TOKEN to a secret."
fi

# The token is read from AUTH_TOKEN in the environment, never from argv.
exec /usr/local/bin/grafana-image-renderer server
