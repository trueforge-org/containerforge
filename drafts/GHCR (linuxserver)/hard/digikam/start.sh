#!/usr/bin/env bash

# UNVERIFIED: the display stack (Xvfb plus a remote-desktop server) must start before
# AppRun and is not chosen yet (plan section 10). AppRun alone will not serve port 3001.

mkdir -p /config/digikam /tmp/cache

export HOME=/config
export XDG_CACHE_HOME=/tmp/cache
export TMPDIR=/tmp

cd /app/digikam
exec ./AppRun
