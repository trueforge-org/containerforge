#!/usr/bin/env bash
set -euo pipefail

export IS_PERSISTENT=1
export PERSIST_DIRECTORY="${PERSIST_DIRECTORY:-/config/chroma}"

mkdir -p "${PERSIST_DIRECTORY}"

exec /app/venv/bin/uvicorn chromadb.app:app \
  --workers "${CHROMA_WORKERS:-1}" \
  --host "${CHROMA_HOST_ADDR:-0.0.0.0}" \
  --port "${CHROMA_HOST_PORT:-8000}" \
  --proxy-headers \
  --timeout-keep-alive "${CHROMA_TIMEOUT_KEEP_ALIVE:-30}"
