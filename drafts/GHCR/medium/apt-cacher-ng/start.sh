#!/usr/bin/env bash
set -euo pipefail

# Cache and logs live on /config (set in acng.conf at build time). Create the directories only when missing.
# The pid file lives in /tmp.
mkdir -p /config/cache /config/log /tmp/apt-cacher-ng

# The daemon runs as apps, not as the package user apt-cacher-ng.
# UNVERIFIED: confirm the daemon accepts a non-root user for CacheDir and LogDir on the first run.
exec /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng
