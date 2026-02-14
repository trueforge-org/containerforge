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

mkdir -p /config/data

if [[ ! -f "/config/data/pwndrop.db" ]]; then
    SECRET_PATH=${SECRET_PATH:-/pwndrop}
    echo "New install detected, starting pwndrop with secret path ${SECRET_PATH}"
    echo -e "\n[setup]\nsecret_path = \"${SECRET_PATH}\"" >> /defaults/pwndrop.ini
fi

exec /app/pwndrop/pwndrop \
                -debug \
                -no-autocert \
                -no-dns \
                -config /defaults/pwndrop.ini

