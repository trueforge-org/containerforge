#!/usr/bin/env bash


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

