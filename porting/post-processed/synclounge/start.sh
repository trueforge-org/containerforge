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

if [ -n "${AUTH_LIST}" ]; then
    export authentication__mechanism='["plex"]'
    export authentication__type='["server", "user"]'
    export authentication__authorized="[\"$(echo ${AUTH_LIST} | sed 's|,|", "|g')\"]"
fi


exec synclounge

