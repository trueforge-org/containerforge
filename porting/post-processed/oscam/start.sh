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
	/config/oscam

# copy config
if [[ ! -e /config/oscam/oscam.conf ]]; then
	cp /defaults/oscam.conf /config/oscam/oscam.conf
fi


## TODO: deal with multi exec
exec /usr/bin/oscam -c /config/oscam

exec /usr/sbin/pcscd -f

