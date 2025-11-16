# ===== From ./processed/fail2ban/root/etc/s6-overlay//s6-rc.d/init-fail2ban-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p \
    /config/log/fail2ban \
    /config/fail2ban/{action.d,filter.d,jail.d}

# copy/update the fail2ban configs from /defaults to /config
cp -R /defaults/fail2ban /config

# symlink fail2ban configs to /config
rm -rf /etc/fail2ban
ln -s /config/fail2ban /etc/fail2ban

# permissions
chmod -R 644 /etc/logrotate.d
if [[ -f "/config/log/logrotate.status" ]]; then
    chmod 600 /config/log/logrotate.status
fi

lsiown -R abc:abc \
    /config

# ===== From ./processed/fail2ban/root/etc/s6-overlay//s6-rc.d/svc-fail2ban/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

FAIL2BAN_ARGS=()

case "${VERBOSITY:-}" in
-v | -vv | -vvv | -vvvv)
    FAIL2BAN_ARGS+=("${VERBOSITY:-}")
    ;;
*) ;;
esac

FAIL2BAN_ARGS+=("-x" "-f" "start")

exec \
    fail2ban-client "${FAIL2BAN_ARGS[@]}"

