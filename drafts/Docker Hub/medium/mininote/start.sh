#!/usr/bin/env bash

mkdir -p /config/data

cd /app/mininote || exit 1
# UNVERIFIED: upstream runs `yarn start` (shell-form ENTRYPOINT). If yarn does not forward
# signals to node, replace with `exec node <entry>` using the entry from package.json.
exec yarn start
