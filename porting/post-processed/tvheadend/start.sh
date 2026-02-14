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
    /config/comskip

# copy config
if [[ ! -e /config/dvr/config ]]; then
    (mkdir -p /config/dvr/config && cp /defaults/7a5edfbe189851e5b1d1df19c93962f0 /config/dvr/config/7a5edfbe189851e5b1d1df19c93962f0)
fi
if [[ ! -e /config/comskip/comskip.ini ]]; then
    cp /defaults/comskip.ini.org /config/comskip/comskip.ini
fi
if [[ ! -e /config/config ]]; then
    (cp /defaults/config /config/config)
fi

exec /usr/bin/tvheadend -C -c /config $RUN_OPTS

