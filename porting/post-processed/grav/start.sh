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

# Symlink directories
symlinks=(
    /app/www/public/backup
    /app/www/public/logs
    /app/www/public/user
)

shopt -s globstar dotglob

for i in "${symlinks[@]}"; do
    if [[ -d /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
        rm -rf "$i"
    fi
    if [[ ! -d /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
        mv "$i" /config/www/
    fi
    if [[ -d /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
        ln -s /config/www/"$(basename "$i")" "$i"
    fi
done

# Symlink files
symlinks=(
    /app/www/public/robots.txt
)

shopt -s globstar dotglob

for i in "${symlinks[@]}"; do
    if [[ -f /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
        rm -rf "$i"
    fi
    if [[ ! -f /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
        mv "$i" /config/www/
    fi
    if [[ -f /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
        ln -s /config/www/"$(basename "$i")" "$i"
    fi
done

shopt -u globstar dotglob

sed -i 's/enable_auto_updates_check: true/enable_auto_updates_check: false/' /config/www/user/plugins/admin/admin.yaml

## TODO: find exec
