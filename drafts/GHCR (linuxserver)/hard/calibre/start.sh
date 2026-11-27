#!/usr/bin/env bash

# Library directory is a plan choice, not an upstream fact.
mkdir -p /config/library

# UNVERIFIED: binary name and flags for the calibre content server; confirm on first build.
exec /opt/calibre/calibre-server --listen-on 0.0.0.0 --port 8080 /config/library
