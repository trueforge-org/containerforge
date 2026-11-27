#!/usr/bin/env bash

# UNVERIFIED: the display stack (X server or Wayland) is not chosen yet. The check
# below stops the container when no display is set, so it can start only once the
# display layer is added (plan section 10).
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "orcaslicer: neither DISPLAY nor WAYLAND_DISPLAY is set; a display stack is required" >&2
  exit 1
fi

mkdir -p /config/.config /tmp/.cache

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export GDK_BACKEND=x11

cd /config
exec /app/orcaslicer/AppRun
