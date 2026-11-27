#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config/kerio /tmp/run

# Seed the data folder from the packaged template only when it is empty; never overwrite the store.
if [ -z "$(ls -A /config/kerio 2>/dev/null)" ]; then
  cp -a /usr/share/kerio-connect-dist/. /config/kerio/
fi

cd /opt/kerio

# UNVERIFIED: daemon path and arguments. Check the .deb contents and /etc/init.d/kerio-connect.
# Single foreground process, exec'd so signals reach it. No supervisor or sshd.
exec /opt/kerio/mailserver/mailserver /opt/kerio/mailserver
