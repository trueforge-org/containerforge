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
mkdir -p \
    /config/scripts \

# copy config file
if [[ ! -e /config/ha-bridge.config ]]; then
    cp /defaults/ha-bridge.config /config/ha-bridge.config
fi

exec java \
            -jar \
            -Dconfig.file=/config/ha-bridge.config \
            -Dexec.garden=/config/scripts \
            -Dsecurity.key="$SEC_KEY" \
            /app/ha-bridge.jar

