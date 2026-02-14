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

mkdir -p /run/haproxy

if [ "${DISABLE_IPV6}" = 1 ]; then
    BIND_PROTO=":2375"
else
    BIND_PROTO="[::]:2375 v4v6"
fi

sed "s/@@BIND_PROTO@@/${BIND_PROTO}/g" /templates/haproxy.cfg > /run/haproxy/haproxy.cfg

exec /usr/sbin/haproxy -f /run/haproxy/haproxy.cfg -W -db
