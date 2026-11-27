#!/usr/bin/env bash
set -euo pipefail

export TUNNEL_METRICS="${TUNNEL_METRICS:-0.0.0.0:20241}"
export NO_AUTOUPDATE=true

if [ -z "${TUNNEL_TOKEN:-}" ] && [ -z "${TUNNEL_TOKEN_FILE:-}" ]; then
    echo "Please set TUNNEL_TOKEN (or mount a secret and set TUNNEL_TOKEN_FILE). Idling until the container is restarted with a token."
    exec sleep infinity
fi

# cloudflared reads TUNNEL_TOKEN / TUNNEL_TOKEN_FILE from the environment,
# so the secret never appears on the command line.
# UNVERIFIED: --no-autoupdate placement after "tunnel"; drop the flag if rejected (NO_AUTOUPDATE is set anyway).
exec /app/cloudflared tunnel --no-autoupdate run
