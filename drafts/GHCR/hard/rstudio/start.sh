#!/usr/bin/env bash

# Single-user mode: no PAM logins, the server runs as the image user (UNVERIFIED flags, see plan.md section 7).
# Seed config only when missing; never overwrite user state.
mkdir -p /config/rstudio /config/home /config/workspace
[ -f /config/rstudio/rserver.conf ] || touch /config/rstudio/rserver.conf

# /etc/rstudio is read-only at runtime, so the config file is read from /config.
# UNVERIFIED: --config-file, --auth-none and --server-user are not checked against the installed deb.
exec /usr/lib/rstudio-server/bin/rserver \
  --server-daemonize=0 \
  --www-address=0.0.0.0 \
  --www-port=8787 \
  --server-user="$(id -un)" \
  --auth-none=1 \
  --config-file=/config/rstudio/rserver.conf
