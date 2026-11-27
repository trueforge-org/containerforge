#!/usr/bin/env bash

# UNVERIFIED: the display stack (Xvfb plus a remote desktop) is not chosen yet; it must start before filezilla.
mkdir -p /config/filezilla /tmp/cache

export HOME=/config
export XDG_CONFIG_HOME=/config
export XDG_CACHE_HOME=/tmp/cache

# UNVERIFIED: site list and settings location under $XDG_CONFIG_HOME, confirm on first run
exec filezilla
