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
    /config/www/freshrss

# create symlinks
symlinks=(
    /app/www/data
    /app/www/extensions
)

for i in "${symlinks[@]}"; do
    if [[ -e "$i" && ! -L "$i" ]]; then
        mv "$i" "${i}.bak"
    fi
    if [[ ! -L "$i" ]]; then
        ln -s "/config/www/freshrss/$(basename "$i")" "$i"
    fi
    if [[ ! -d "/config/www/freshrss/$(basename "$i")" ]]; then
        cp -R "${i}.bak" "/config/www/freshrss/$(basename "$i")"
    fi
done

# backwards compatibility
if grep -q 'root /config/www/freshrss/p;' /config/nginx/site-confs/default.conf; then
    cp /defaults/nginx/site-confs/default.conf.sample /config/nginx/site-confs/default.conf
fi

# disable updates
if [[ -f /config/www/freshrss/data/config.php ]]; then
    sed -i "s|'disable_update' => false,|'disable_update' => true,|g" /config/www/freshrss/data/config.php
fi

## TODO: find exec
