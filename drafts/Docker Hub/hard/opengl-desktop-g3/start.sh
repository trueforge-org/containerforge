#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/.config/openbox /config/Desktop /tmp/.cache

# Seed the openbox autostart only when missing. Existing user state is never overwritten.
if [[ ! -s /config/.config/openbox/autostart ]]; then
  cp /defaults/autostart /config/.config/openbox/autostart
fi

# Use VirtualGL's EGL backend only when a render node is present. Without one, Mesa falls back to llvmpipe.
if compgen -G "/dev/dri/renderD*" > /dev/null; then
  export VGL_DISPLAY="${VGL_DISPLAY:-egl}"
  echo "GPU render node found, VirtualGL uses the EGL backend"
else
  echo "No /dev/dri render node, using software Mesa (llvmpipe)"
fi

# Hand over to the base desktop init, renamed by the Dockerfile.
# UNVERIFIED: the base script's own paths and its final exec line (plan section 7).
exec /kasmvnc-start.sh "$@"
