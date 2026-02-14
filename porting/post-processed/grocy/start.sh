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

# create missing cache directory
mkdir -p /app/www/data/viewcache || :

# create symlinks
i=/app/www/data
if [[ -e "$i" && ! -L "$i" && -e /config/"$(basename "$i")" ]]; then
    rm -Rf "$i"
    ln -s /config/"$(basename "$i")" "$i"
fi
if [[ -e "$i" && ! -L "$i" ]]; then
    mv "$i" /config/"$(basename "$i")"
    ln -s /config/"$(basename "$i")" "$i"
fi

# check for config file and copy default if needed
if [[ ! -f "/config/data/config.php" ]]; then
    cp /app/www/config-dist.php /config/data/config.php
fi

if [[ ! -f "/config/data/plugins/DemoBarcodeLookupPlugin.php" ]]; then
    cp -R /defaults/plugins /config/data
fi

## TODO: find exec
