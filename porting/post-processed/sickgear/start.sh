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

#make our folders and links
mkdir -p \
    /config

# If needed add dafault config
if [[ ! -f /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

exec python3 /app/sickgear/sickgear.py --datadir /config

