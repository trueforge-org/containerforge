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

# setup web
mkdir -p \
    /config/diskover-web.conf.d

# touch db
if [[ ! -e "/config/diskoverdb.sqlite3" ]]; then
    touch /config/diskoverdb.sqlite3
fi

if [ -f "/config/diskover.cfg" ]; then
    echo '
******************************************************
******************************************************
*                                                    *
*                                                    *
*     We have detected that you have an existing     *
*                                                    *
*   diskover v1 config file. Version 1 is now EOL.   *
*                                                    *
*    If you would like to upgrade, please create a   *
*                                                    *
*   new /config directory. If you want to continue   *
*                                                    *
*  using version 1, specify the tag v1.5.0.13-ls33.  *
*                                                    *
*                More information at                 *
*                                                    *
* https://github.com/diskoverdata/diskover-community *
*                                                    *
*                                                    *
******************************************************
******************************************************'
    while true; do
        sleep 3600
    done
fi

