#!/usr/bin/env bash

mkdir -p /config/datadir

# UNVERIFIED: the binary name, its flags and how it selects the data dir are not known yet. Read `dpkg -c` and the vendor docs first.
# Placeholder, not a working launch command:
cd /app/mymediaforalexa || exit 1
exec ./mymedia --datadir /config/datadir
