#!/usr/bin/env bash
# NONROOT_COMPAT
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  shopt -s expand_aliases
  alias apk=':'
  alias apt-get=':'
  alias chown=':'
  alias chmod=':'
  alias usermod=':'
  alias groupadd=':'
  alias adduser=':'
  alias useradd=':'
  alias setcap=':'
  alias mount=':'
  alias sysctl=':'
  alias service=':'
  alias s6-svc=':'
fi

# make folders
mkdir -p \
    /config/configs

# generate license file
if [[ ! -f /config/znc.pem ]]; then
    /usr/local/bin/znc -d /config -p
fi

while [[ ! -f "/config/znc.pem" ]]; do
    echo "waiting for pem file to be generated"
    sleep 2s
done

# copy config
if [[ ! -f /config/configs/znc.conf ]]; then
    cp /defaults/znc.conf /config/configs/znc.conf
fi

PORT=$(grep "Port =" /config/configs/znc.conf | awk -F '=' '{print $2;exit}')

exec /usr/local/bin/znc -d /config \
        --foreground

