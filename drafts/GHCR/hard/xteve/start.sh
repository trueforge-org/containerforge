#!/usr/bin/env bash

# UNVERIFIED: xTeVe may write its configuration relative to the working directory. Confirm with an empty /config.
cd /config || exit 1
exec /app/xteve
