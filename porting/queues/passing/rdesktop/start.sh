#!/usr/bin/env bash


if [[ ! -f "/keylock" ]]; then
    cd /etc/xrdp || exit 1
    xrdp-keygen xrdp
    rm -f /etc/xrdp/*.pem
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/xrdp/key.pem \
    -out /etc/xrdp/cert.pem \
    -subj "/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
    touch /keylock
fi

mkdir -p /var/run/xrdp || exit 1
chown root:xrdp /var/run/xrdp || exit 1
chmod 2775 /var/run/xrdp || exit 1

mkdir -p /var/run/xrdp/sockdir || exit 1
chown root:xrdp /var/run/xrdp/sockdir || exit 1
chmod 3777 /var/run/xrdp/sockdir || exit 1

# default file copies first run
if [[ ! -d /config/.config ]]; then
  mkdir -p /config/.config
  cp /defaults/bashrc /config/.bashrc
  cp /defaults/startwm.sh /config/startwm.sh
fi
if [[ ! -f /config/.config/openbox/autostart ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/autostart /config/.config/openbox/autostart
fi
if [[ ! -f /config/.config/openbox/menu.xml ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/menu.xml /config/.config/openbox/menu.xml
fi

# XDG Home
printf "/config/.XDG" > /run/s6/container_environment/XDG_RUNTIME_DIR
if [ ! -d "/config/.XDG" ]; then
  mkdir -p /config/.XDG
  chown apps:apps /config/.XDG
fi

# Locale Support
if [ ! -z ${LC_ALL+x} ]; then
  printf "${LC_ALL%.UTF-8}" > /run/s6/container_environment/LANGUAGE
  printf "${LC_ALL}" > /run/s6/container_environment/LANG
fi

# Remove window borders
if [[ ! -z ${NO_DECOR+x} ]] && [[ ! -f /decorlock ]]; then
  sed -i \
    's|</applications>|  <application class="*"> <decor>no</decor> </application>\n</applications>|' \
    /etc/xdg/openbox/rc.xml
  touch /decorlock
fi

# Fullscreen everything in openbox unless the user explicitly disables it
if [[ ! -z ${NO_FULL+x} ]] && [[ ! -f /fulllock ]]; then
  sed -i \
    '/<application class="\*"><maximized>yes<\/maximized><\/application>/d' \
    /etc/xdg/openbox/rc.xml
  touch /fulllock
fi

# Add proot-apps
if [ ! -f "/config/.local/bin/proot-apps" ]; then
  mkdir -p /config/.local/bin/
  cp /proot-apps/* /config/.local/bin/
  echo 'export PATH="/config/.local/bin:$PATH"' >> /config/.bashrc
  chown apps:apps \
    /config/.bashrc \
    /config/.local/ \
    /config/.local/bin \
    /config/.local/bin/{ncat,proot-apps,proot,jq,pversion}
elif ! diff -q /proot-apps/pversion /config/.local/bin/pversion > /dev/null; then
  cp /proot-apps/* /config/.local/bin/
  chown apps:apps /config/.local/bin/{ncat,proot-apps,proot,jq,pversion}
fi

# permissions
PERM=$(stat -c '%U' /config/.config)
if [[ "${PERM}" != "apps" ]]; then
    chown -R apps:apps /config
fi

#! /usr/bin/execlineb -P

# Move stderr to out so it's piped to logger
fdmove -c 2 1

# Notify service manager when xrdp is up


# set env
s6-env DISPLAY=:1

/usr/sbin/xrdp --nodaemon

# Redirect stderr to stdout.
fdmove -c 2 1

# Notify service manager when xrdp is up

## TODO check
exec /usr/sbin/xrdp-sesman --nodaemon

