#!/usr/bin/env bash

# persistent state (config, database, cloud identity) lives in /config; caches and logs go to /tmp
mkdir -p /config/netdata/etc /config/netdata/lib /tmp/netdata/cache /tmp/netdata/log

# seed the stock config only when it is missing or empty; never overwrite user changes
if [ -z "$(ls -A /config/netdata/etc 2>/dev/null)" ]; then
  # UNVERIFIED: the stock config path inside the installed tree.
  cp -a /app/netdata/etc/netdata/. /config/netdata/etc/
fi

# UNVERIFIED: the directory variables netdata honours. Check `netdata -W` or the [directories] section of the stock netdata.conf in the first build round.
export NETDATA_CONFIG_DIR=/config/netdata/etc
export NETDATA_LIB_DIR=/config/netdata/lib
export NETDATA_CACHE_DIR=/tmp/netdata/cache
export NETDATA_LOG_DIR=/tmp/netdata/log

# UNVERIFIED: the dashboard must bind to 0.0.0.0 ([web] bind to in netdata.conf). Check it from outside the container.

# run in the foreground so netdata is PID 1 and receives signals
# UNVERIFIED: the binary path inside the installed tree.
exec /app/netdata/usr/sbin/netdata -D
