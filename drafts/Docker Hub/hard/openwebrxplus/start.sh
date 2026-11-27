#!/usr/bin/env bash
set -euo pipefail

# Config under /config/etc (reached through the /etc/openwebrx symlink), data under /config/data,
# scratch under /tmp (the rootfs is read-only).
mkdir -p /config/etc/openwebrx.conf.d /config/data /config/plugins /tmp/openwebrx

# First run only: seed the image defaults, never overwrite user files.
cp -n /defaults/openwebrx.conf /config/etc/openwebrx.conf
cp -rn /etc/openwebrx.dist/. /config/etc/

# Optional admin account, created once. The password goes through the environment, not argv.
# UNVERIFIED: `openwebrx admin` sub-commands and flags (taken from upstream's entrypoint behaviour).
if [[ -n "${OPENWEBRX_ADMIN_USER:-}" && -n "${OPENWEBRX_ADMIN_PASSWORD:-}" ]]; then
  if ! openwebrx admin --silent hasuser "${OPENWEBRX_ADMIN_USER}"; then
    OWRX_PASSWORD="${OPENWEBRX_ADMIN_PASSWORD}" \
      openwebrx admin --noninteractive adduser "${OPENWEBRX_ADMIN_USER}"
  fi
fi

# codecserver is installed by the plan's full set but not started here yet (plan.md section 7, step 5).

# Hand over to openwebrx so signals reach the main process.
exec openwebrx
