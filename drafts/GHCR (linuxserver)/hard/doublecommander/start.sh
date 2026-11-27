#!/usr/bin/env bash

# BLOCKED (plan section 10): Double Commander needs an X display. Start the chosen display stack here first, in the same script, with the GUI process in the foreground.

mkdir -p /config/doublecommander /tmp/cache

# UNVERIFIED: the config directory name the binary creates, and whether it honours XDG_CONFIG_HOME
export XDG_CONFIG_HOME=/config XDG_CACHE_HOME=/tmp/cache

cd /app/doublecommander
exec ./doublecmd
