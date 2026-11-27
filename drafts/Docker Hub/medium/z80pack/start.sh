#!/usr/bin/env bash

# Seed the disk folder from the packaged library only when it is empty; never overwrite.
mkdir -p /config/cpmsim/disks /tmp/shellinabox

if [ -z "$(ls -A /config/cpmsim/disks 2>/dev/null)" ] && [ -d /app/z80pack/cpmsim/disks/library ]; then
  cp -rn /app/z80pack/cpmsim/disks/library/. /config/cpmsim/disks/
fi

# UNVERIFIED: shellinaboxd flags and the service spec (url:user:group:dir:cmd) must be checked against the installed binary.
# Auth is an open decision: the terminal currently has no login. Do not publish without deciding this in the PR.
exec shellinaboxd \
  -p 4200 \
  -c /tmp/shellinabox \
  --no-beep \
  -s "/:apps:apps:/config/cpmsim:/app/z80pack/cpmsim/cpm22"
