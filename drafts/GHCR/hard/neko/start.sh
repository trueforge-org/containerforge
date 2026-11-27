#!/usr/bin/env bash
# UNVERIFIED draft (plan section 7): the supervisord config path below is a proposal, not confirmed from the neko base.
set -euo pipefail

mkdir -p /config/neko /config/profile /tmp/neko

# Supervisord runs Xorg, openbox, pulseaudio and the neko server in the foreground.
# UNVERIFIED: the neko server must listen on 0.0.0.0:8080 (not localhost).
exec supervisord -n -c /etc/neko/supervisord.conf
