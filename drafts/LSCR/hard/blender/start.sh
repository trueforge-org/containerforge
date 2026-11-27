#!/usr/bin/env bash

set -eu

mkdir -p /config/blender
cd /config/blender

export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp &

# BLOCKED (plan section 10): no web viewer on 3001 yet (kasmvnc pattern, UNVERIFIED).
exec /usr/bin/blender
