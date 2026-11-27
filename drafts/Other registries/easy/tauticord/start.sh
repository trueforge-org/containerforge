#!/usr/bin/env bash

mkdir -p /config

cd /app || exit 1
# UNVERIFIED: the upstream entry is entrypoint.sh (Dockerfile ENTRYPOINT). Its contents, env names and
# write paths were not read from the 6.2.0 tag. Replace this with the real entry once it is checked.
exec sh /app/entrypoint.sh
