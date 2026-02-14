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
    /config/{album-art,db,keys,logs,sync} \
    /music

# create keys
if [[ ! -e /config/keys/certificate.pem ]]; then
    openssl req -x509 -nodes -days 3650 \
    -newkey rsa:2048 -keyout /config/keys/private-key.pem  -out /config/keys/certificate.pem \
    -subj "/CN=mstream"
fi

# copy config.json if doesn't exist
if [[ ! -e /config/config.json ]]; then
    cp /defaults/config.json /config/config.json
fi

if grep -q '"webAppDirectory": "public"' /config/config.json; then
    mv /config/config.json /config/config.json.v4-bak
    echo '
*************************************
*************************************
****                             ****
****                             ****
****   v4 config.json detected   ****
****                             ****
****   renaming to               ****
****                             ****
****   config.json.v4-bak        ****
****                             ****
****   due to incompatibility    ****
****                             ****
****   with v5                   ****
****                             ****
*************************************
*************************************'
fi

PORT=$(jq -r '.port' /config/config.json)

cd /app/mstream
exec mstream -j /config/config.json

