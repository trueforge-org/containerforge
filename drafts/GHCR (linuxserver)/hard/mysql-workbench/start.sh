#!/usr/bin/env bash

# UNVERIFIED: workbench profile path under $HOME, confirm on first run.
# A display (DISPLAY or WAYLAND_DISPLAY) is required; the display layer is an open decision.
mkdir -p /config/.mysql/workbench /tmp/.cache

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache

if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  echo "mysql-workbench: no DISPLAY or WAYLAND_DISPLAY set, the GUI cannot start" >&2
  exit 1
fi

cd /config || exit 1
# UNVERIFIED: binary path, confirm with dpkg -L mysql-workbench-community
exec /usr/bin/mysql-workbench
