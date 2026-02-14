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

# create symlinks
sitepackages=$(python -c "import site; print(site.getsitepackages()[0])")

symlinks=(
    "${sitepackages}"/sickchill/gui/slick/cache
)
for i in "${symlinks[@]}"; do
    rm -rf "$i"
    ln -s /config/"$(basename "$i")" "$i"
done

# permissions
echo "Setting permissions"

exec python3 /config/venv/bin/SickChill --datadir /config

