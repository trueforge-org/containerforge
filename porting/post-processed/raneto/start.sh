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

folders=(
    /app/raneto/node_modules/@raneto/theme-default/dist/public/images
    /app/raneto/content
    /app/raneto/config
    /app/raneto/sessions
)

for i in "${folders[@]}"; do
    if [[ -e "$i" && ! -L "$i" && -e /config/"$(basename "$i")" ]]; then
        rm -Rf "$i" && \
        ln -s /config/"$(basename "$i")" "$i"
    fi

    if [[ -e "$i" && ! -L "$i" ]]; then
        mv "$i" /config/"$(basename "$i")" && \
        ln -s /config/"$(basename "$i")" "$i"
    fi
done

# upgrade support
if [[ -f /config/config.default.js ]]; then
  mv /config/config.default.js /config/config/config.js
fi

# copy default config
if [[ ! -f /config/config/config.js ]]; then
    cp /defaults/config.js /config/config/config.js
fi

HOST=0.0.0.0
cd /app/raneto
exec node server.js

