#!/usr/bin/env bash

# UNVERIFIED: how upstream starts Redis and the Python workers (the Go server may start them itself).
# Confirm from server/server.go and from a test run before relying on this script.
# UNVERIFIED: init.py is idempotent and reads DATA_DIR.
mkdir -p /config/datastore /tmp/deeptemp
cd /app
python3 /app/init.py
cd /app/server
exec /app/server/server
