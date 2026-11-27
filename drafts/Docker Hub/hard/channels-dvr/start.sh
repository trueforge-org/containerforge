#!/usr/bin/env bash

mkdir -p /config /shares/DVR 2>/dev/null || true

# UNVERIFIED: the server's data directory. setup.sh puts the server under /app, which is read-only at runtime,
# and the upstream image keeps its data in /channels-dvr. Find the flag or env var that moves the data to /config
# before the first run. Until then, state is written under /app and this start fails on a read-only rootfs.
# UNVERIFIED: the apps user needs the video and render groups for /dev/dri (hardware transcoding only).
cd /app/channels-dvr/latest
exec ./channels-dvr
