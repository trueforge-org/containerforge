#!/usr/bin/env bash
set -euo pipefail

export NTFY_LISTEN_HTTP="${NTFY_LISTEN_HTTP:-:8080}"
export NTFY_CACHE_FILE="${NTFY_CACHE_FILE:-/config/cache.db}"
export NTFY_AUTH_FILE="${NTFY_AUTH_FILE:-/config/user.db}"

mkdir -p "$(dirname "${NTFY_CACHE_FILE}")" "$(dirname "${NTFY_AUTH_FILE}")"
# Attachments may also use an s3:// URL, so only create local paths.
if [[ "${NTFY_ATTACHMENT_CACHE_DIR:-}" == /* ]]; then
  mkdir -p "${NTFY_ATTACHMENT_CACHE_DIR}"
fi

# Optional user config file. ntfy also reads env vars.
args=(serve)
if [[ -f /config/server.yml ]]; then
  args+=(--config /config/server.yml)
fi

exec /app/ntfy "${args[@]}"
