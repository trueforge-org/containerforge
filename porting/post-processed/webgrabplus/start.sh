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

mkdir -p \
    /app/wg++/bin.net/WebGrab+Plus \
    /config/License
ln -sf /config/License /app/wg++/bin.net/WebGrab+Plus

# copy config
if [[ ! -e /config/WebGrab++.config.xml ]]; then
    cp /defaults/WebGrab++.config.xml /config/
fi

if [[ ! -e /config/siteini.pack ]]; then
    cp -R /defaults/ini/siteini.pack /config/
fi

## TODO: figure out exec
