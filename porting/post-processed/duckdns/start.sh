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

#Check to make sure the subdomain and token are set
if [ -z "${SUBDOMAINS}" ] || [ -z "${TOKEN}" ]; then
    echo "Please pass both your subdomain(s) and token as environment variables in your docker run command. See the readme for more details."
    sleep infinity
fi

if [[ ! -f /config/logrotate.conf ]]; then
    cp /defaults/logrotate.conf /config/logrotate.conf
    chmod 640 /config/logrotate.conf
fi

# run initial IP update
exec /app/duck.sh

