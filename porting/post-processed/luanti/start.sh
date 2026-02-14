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
    /config/.minetest/games \
    /config/.minetest/mods \
    /config/.minetest/main-config

if [[ ! -f "/config/.minetest/main-config/minetest.conf" ]]; then
    cp /defaults/minetest.conf /config/.minetest/main-config/minetest.conf
fi

if [[ ! -d "/config/.minetest/games/minimal" ]]; then
    cp -pr /defaults/games/* /config/.minetest/games/
fi

exec luantiserver --port 30000 \
        --config /config/.minetest/main-config/minetest.conf ${CLI_ARGS}

