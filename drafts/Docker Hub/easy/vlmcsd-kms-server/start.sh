#!/usr/bin/env bash
# Stateless: nothing is written to /app or /config.
# -D foreground, -e log to stdout, -L explicit IPv4 bind on 1688 (all interfaces).
# UNVERIFIED: whether -v (verbose, logs every request) is wanted in production; dropping it reduces log volume.

exec /app/vlmcsd -D -e -v -t 30 -L 0.0.0.0:1688
