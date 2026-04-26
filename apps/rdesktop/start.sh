#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config/{.config,logs,.XDG,.local/bin,xrdp}

[[ -f /config/.bashrc ]] || cp /defaults/bashrc /config/.bashrc
[[ -f /config/startwm.sh ]] || cp /defaults/startwm.sh /config/startwm.sh

if [[ ! -f /config/.config/openbox/autostart ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/autostart /config/.config/openbox/autostart
fi

if [[ ! -f /config/.config/openbox/menu.xml ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/menu.xml /config/.config/openbox/menu.xml
fi

cp -n /proot-apps/* /config/.local/bin/ || true
grep -q '/config/.local/bin' /config/.bashrc || echo 'export PATH="/config/.local/bin:$PATH"' >> /config/.bashrc

cp -n /etc/xrdp/xrdp.ini /config/xrdp/xrdp.ini
cp -n /etc/xrdp/sesman.ini /config/xrdp/sesman.ini

mkdir -p /tmp/xrdp/sockdir
sed -i 's|^LogFile=.*|LogFile=/config/logs/xrdp.log|' /config/xrdp/xrdp.ini
sed -i 's|^port=.*|port=3389|' /config/xrdp/xrdp.ini
sed -i 's|^LogFile=.*|LogFile=/config/logs/xrdp-sesman.log|' /config/xrdp/sesman.ini
sed -i 's|^FuseMountName=.*|FuseMountName=/tmp/xrdp/thinclient_drives|' /config/xrdp/sesman.ini

export XDG_RUNTIME_DIR=/config/.XDG

/usr/sbin/xrdp-sesman --nodaemon --config /config/xrdp/sesman.ini &
exec /usr/sbin/xrdp --nodaemon --config /config/xrdp/xrdp.ini
