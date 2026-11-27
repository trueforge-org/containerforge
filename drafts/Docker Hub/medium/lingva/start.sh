#!/usr/bin/env bash

# next start writes its image cache under .next/cache, which is a symlink to /tmp/next-cache
mkdir -p /tmp/next-cache

cd /app/lingva || exit 1

# UNVERIFIED: next flags for the Next.js version in the lockfile
exec ./node_modules/.bin/next start -H 0.0.0.0 -p 3000 "$@"
