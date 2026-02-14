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

# make our folders
mkdir -p \
    /run/ddclient-cache \
    /run/ddclient

# copy default config if not present in /config
if [[ ! -e /config/ddclient.conf ]]; then
    cp /defaults/ddclient.conf /config
fi

chmod 700 \
    /config \
    /run/ddclient-cache

chmod 600 \
    /config/*

exec /usr/bin/ddclient --foreground --file /config/ddclient.conf --cache /run/ddclient-cache/ddclient.cache

## TODO: we have to handle this differently
# starting inotify to watch /config/ddclient.conf and restart ddclient if changed.
while inotifywait -e modify /config/ddclient.conf; do
    chmod 600 /config/ddclient.conf
    s6-svc -h /run/service/svc-ddclient
    echo "ddclient has been restarted"
done

