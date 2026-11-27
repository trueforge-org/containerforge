#!/usr/bin/env bash
set -eu

# Persistent state (key material) lives in /config. Create it only when missing.
# The chart uses /state with "-state state". This image uses /config instead.
mkdir -p /config/state
cd /config

# UNVERIFIED: flags are copied from the chart ARGS, not from upstream run.sh (not read).
# -orport points at a local Tor ORPort that is not part of this image (UNVERIFIED that the listener opens without it).
# -logLevel DEBUG is the chart value. Consider a quieter default after the first run.
exec /app/shapeshifter-dispatcher \
    -transparent \
    -server \
    -state /config/state \
    -orport 127.0.0.1:3333 \
    -transports obfs4 \
    -bindaddr obfs4-0.0.0.0:2222 \
    -logLevel DEBUG \
    -enableLogging
