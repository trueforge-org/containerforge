#!/usr/bin/env bash
set -euo pipefail

# Configuration is read from environment variables on each request, so there is no seeding.
# Nothing is written under /app. UNVERIFIED: whether Next.js writes .next/cache at runtime,
# which would fail on the read-only rootfs.
cd /app
exec node server.js
