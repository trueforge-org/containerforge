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

if [[ -z ${DB_TYPE} ]]; then
    printf "sqlite" > /run/s6/container_environment/DB_TYPE
fi

if [[ ! -f "/config/config.yml" ]]; then
    cp /defaults/config.yml /config/config.yml
fi

export CONFIG_FILE="/config/config.yml"

cd /app/wiki
exec /usr/bin/node server
