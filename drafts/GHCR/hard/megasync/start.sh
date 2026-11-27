#!/usr/bin/env bash
# UNVERIFIED: the upstream /opt/scripts/start.sh was not read. This launch sequence is a plan decision.
# UNVERIFIED: TigerVNC option names, the websockify and noVNC paths, and the MEGAsync flags needed as a non-root user.
# The VNC server has no auth (SecurityTypes None). It binds to localhost, and only noVNC on 8080 is exposed.
set -eu

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export DISPLAY=:1

mkdir -p "${DATA_DIR}" /tmp/.cache
if [ ! -d /tmp/.X11-unix ]; then
    mkdir -m 1777 /tmp/.X11-unix
fi

Xvnc :1 \
    -geometry "${CUSTOM_RES_W}x${CUSTOM_RES_H}" \
    -depth "${CUSTOM_DEPTH}" \
    -SecurityTypes None \
    -rfbport 5900 &

# Wait for the VNC server to accept connections before starting the web proxy.
for _ in $(seq 1 30); do
    (exec 3<>/dev/tcp/127.0.0.1/5900) 2>/dev/null && break
    sleep 1
done

websockify --web /usr/share/novnc 8080 localhost:5900 &

exec /usr/bin/megasync
