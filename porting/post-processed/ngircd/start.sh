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

# make our folders
mkdir -p \
    /var/run/ngircd

# copy config
if [[ ! -f /config/ngircd.conf ]]; then
    cp /defaults/ngircd.conf /config/ngircd.conf
fi

exec /usr/sbin/ngircd -n -f /config/ngircd.conf

