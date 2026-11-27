#!/usr/bin/env bash

mkdir -p /config /config/Downloads /config/Share

# Seed only missing files, never overwrite user state.
# UNVERIFIED: defaults/web-users.json (default admin) is not written yet, because the upstream
# password hash is not in the plan. Create the first user with airdcppd --add-user if needed.
for f in DCPlusPlus.xml web-server.json; do
  [[ -s /config/$f ]] || cp /defaults/$f /config/$f
done

# -c overrides the portable dcppboot.xml (ConfigPath ./config/).
# UNVERIFIED: if paths still resolve under /app/airdcpp-webclient, remove dcppboot.xml in the Dockerfile.
exec /app/airdcpp-webclient/airdcppd -c=/config \
  --web-resources=/app/airdcpp-webclient/web-resources
