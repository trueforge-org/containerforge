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

# make folders
mkdir -p /config/{mylar,scripts}

# copy scripts folder to config
if [[ ! -f /config/scripts/autoProcessComics.py ]]; then
    cp -pr /app/mylar3/post-processing/* /config/scripts/
fi

exec python3 /app/mylar3/Mylar.py --nolaunch \
        --datadir /config/mylar

