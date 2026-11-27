#!/usr/bin/env bash

args=()
if [ -n "${SYNO_THUMBS:-}" ]; then
  args+=(--syno)
fi
if [ -n "${ONDEMAND_THUMBS:-}" ]; then
  args+=(--nothumbs)
fi

mkdir -p /config /thumbs /pictures 2>/dev/null || true

cd /app
bin=./Damselfly.Web.Server
if [ -n "${DAMSELFLY_BLAZORSERVER:-}" ]; then
  # UNVERIFIED: Damselfly.Web (Blazor Server) may not be in the release zip.
  bin=./Damselfly.Web
fi

exec "${bin}" /pictures --config=/config --thumbs=/thumbs "${args[@]}"
