#!/usr/bin/env bash

# BLOCKED (plan section 10): Remmina needs an X display. The display server and remote bridge are not chosen yet.

# Create state directories only. Nothing is seeded, and nothing is written under /app.
mkdir -p /config/xdg/remmina /tmp/cache /tmp/runtime
chmod 0700 /tmp/runtime

# UNVERIFIED: fixed display number and start of the chosen display server, then wait for its socket.
# export DISPLAY=:99

# UNVERIFIED: whether remmina needs a session D-Bus. If it does, wrap with dbus-run-session.
exec remmina
