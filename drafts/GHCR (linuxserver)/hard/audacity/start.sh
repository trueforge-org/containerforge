#!/usr/bin/env bash

# BLOCKED (plan section 10): Audacity needs a display server, which this base does not provide.
# Start the chosen display stack here before launching the app. Do not write under /app.

mkdir -p /config

cd /app/audacity
# UNVERIFIED: AppRun is the AppImage entry point for 4.0.2
exec ./AppRun
