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
    /config/fonts

# copy config
if [[ ! -f /config/preferences.json ]]; then
    cp /defaults/preferences.json /config/preferences.json
fi

JAVAMEM=${MAXMEM:-512}
PORT=$(jq -r '.adminPortNumber' < /config/preferences.json)

cd /app/ubooquity
exec java -Xmx"$JAVAMEM"m \
        -jar /app/ubooquity/Ubooquity.jar \
        --headless --host 0.0.0.0 --remoteadmin \
        --workdir /config

