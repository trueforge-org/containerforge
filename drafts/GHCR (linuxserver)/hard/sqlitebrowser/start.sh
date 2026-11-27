#!/usr/bin/env bash

# BLOCKED (plan section 10): sqlitebrowser needs an X display. The display server and remote bridge are not chosen yet.

# Create state directories only. Nothing is seeded, and nothing is written under /app.
mkdir -p /config/xdg /tmp/cache /tmp/runtime
chmod 0700 /tmp/runtime

# UNVERIFIED: fixed display number and start of the chosen display server, then wait for its socket.
# export DISPLAY=:99

# UNVERIFIED: QT_QPA_PLATFORM=offscreen is only for headless use, and is not known to work for this app.
exec sqlitebrowser
