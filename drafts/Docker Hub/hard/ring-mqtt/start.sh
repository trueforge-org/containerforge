#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/go2rtc

# Seed config.json only when it is missing. Never overwrite user state.
if [ ! -f /config/config.json ]; then
  cp /defaults/config.json /config/config.json
fi

# go2rtc streaming helper: RTSP on all interfaces, API on localhost only.
# UNVERIFIED: upstream may launch go2rtc itself (scripts/ in v5.9.3). Read that launcher and match it before relying on this config.
cat > /tmp/go2rtc/go2rtc.yaml <<'EOF'
api:
  listen: "127.0.0.1:1984"
rtsp:
  listen: "0.0.0.0:8554"
EOF
/usr/local/bin/go2rtc -config /tmp/go2rtc/go2rtc.yaml &

# Without a Ring refresh token the app serves its web authentication UI on 55123.
cd /app/ring-mqtt
exec node ring-mqtt.js
