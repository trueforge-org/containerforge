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

mkdir -p \
    /config/log/fail2ban \
    /config/fail2ban/{action.d,filter.d,jail.d}

# copy/update the fail2ban configs from /defaults to /config
cp -R /defaults/fail2ban /config

# symlink fail2ban configs to /config

# permissions
chmod -R 644 /etc/logrotate.d
if [[ -f "/config/log/logrotate.status" ]]; then
    chmod 600 /config/log/logrotate.status
fi

FAIL2BAN_ARGS=()

case "${VERBOSITY:-}" in
-v | -vv | -vvv | -vvvv)
    FAIL2BAN_ARGS+=("${VERBOSITY:-}")
    ;;
*) ;;
esac

FAIL2BAN_ARGS+=("-x" "-f" "start")

exec fail2ban-client "${FAIL2BAN_ARGS[@]}"

