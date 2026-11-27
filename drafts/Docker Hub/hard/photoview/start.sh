#!/usr/bin/env bash
# UNVERIFIED: the exact startup log text of Photoview and its readiness signal.
set -euo pipefail

: "${PHOTOVIEW_DATABASE_DRIVER:=sqlite}"
: "${PHOTOVIEW_SQLITE_PATH:=/config/photoview.db}"
: "${PHOTOVIEW_POSTGRES_URL:=}"
: "${PHOTOVIEW_LISTEN_IP:=0.0.0.0}"
: "${PHOTOVIEW_LISTEN_PORT:=8080}"
: "${PHOTOVIEW_MEDIA_CACHE:=/cache}"
: "${PHOTOVIEW_SERVE_UI:=1}"
: "${PHOTOVIEW_UI_PATH:=/app/ui}"
: "${PHOTOVIEW_API_ENDPOINT:=/api}"
: "${PHOTOVIEW_FACE_RECOGNITION_MODELS_PATH:=/app/data/models}"
: "${MAPBOX_TOKEN:=}"
: "${TZ:=Etc/UTC}"

export PHOTOVIEW_DATABASE_DRIVER PHOTOVIEW_SQLITE_PATH PHOTOVIEW_POSTGRES_URL \
  PHOTOVIEW_LISTEN_IP PHOTOVIEW_LISTEN_PORT PHOTOVIEW_MEDIA_CACHE PHOTOVIEW_SERVE_UI \
  PHOTOVIEW_UI_PATH PHOTOVIEW_API_ENDPOINT PHOTOVIEW_FACE_RECOGNITION_MODELS_PATH \
  MAPBOX_TOKEN TZ

if [ "${PHOTOVIEW_DATABASE_DRIVER}" = "postgres" ] && [ -z "${PHOTOVIEW_POSTGRES_URL}" ]; then
  echo "ERROR: PHOTOVIEW_DATABASE_DRIVER=postgres needs PHOTOVIEW_POSTGRES_URL to be set." >&2
  exit 1
fi

# Only /config and /cache are writable. Scratch space goes to /tmp.
mkdir -p /config "${PHOTOVIEW_MEDIA_CACHE}" /tmp/photoview

cd /app
exec /app/photoview
