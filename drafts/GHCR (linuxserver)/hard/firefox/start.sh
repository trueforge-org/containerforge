#!/usr/bin/env bash
# shellcheck shell=bash

# Firefox needs a display. Fail with a clear message instead of exiting silently.
if [[ -z "${DISPLAY:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "firefox: neither DISPLAY nor WAYLAND_DISPLAY is set; a display layer is required" >&2
    exit 1
fi

mkdir -p /config/profile /tmp/.cache

cd /config || exit 1

exec /app/firefox/firefox \
    --profile /config/profile \
    --no-remote
