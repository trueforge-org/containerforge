#!/usr/bin/env bash

# The server keeps its config, logs and library data in /config. Only that path is written.
mkdir -p /config
cd /config || exit 1

# UNVERIFIED: the arguments that start the web server. Check the upstream wrapper's service run script before the first run.
exec /app/bin/YACReaderLibraryServer
