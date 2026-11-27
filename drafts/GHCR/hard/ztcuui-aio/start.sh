#!/bin/bash
set -euo pipefail

# State lives in /config through symlinks made at build time:
# /var/lib/zerotier-one, /etc/zt-mkworld and /opt/key-networks/ztncui/etc.
mkdir -p /config/zerotier-one /config/zt-mkworld /config/ztncui-etc

# UNVERIFIED: zerotier-one needs /dev/net/tun and CAP_NET_ADMIN; this step fails without them
zerotier-one -d

cd /opt/key-networks/ztncui
# UNVERIFIED: start_ztncui.sh from upstream was not read; this entry point is a guess
exec node src/main.js
