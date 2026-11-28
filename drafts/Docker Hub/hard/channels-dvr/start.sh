#!/usr/bin/env bash

# /app/channels-dvr/data is a symlink to /config (set in the Dockerfile), because /app is read-only.
# UNVERIFIED: the server resolves its data directory as ../data relative to the version directory,
# as the vendor installer lays it out. Check the first-run log for the path it reports.
mkdir -p /config 2>/dev/null || true
mkdir -p /shares/DVR 2>/dev/null || true

# UNVERIFIED: the apps user needs the video and render groups for /dev/dri (hardware transcoding only).
cd /app/channels-dvr/latest || exit 1
exec ./channels-dvr
