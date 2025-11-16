# ===== From ./processed/syslog-ng/root/etc/s6-overlay//s6-rc.d/init-syslog-ng-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

#Copy defaults
SYSLOG_VERSION=$(syslog-ng --version 2>/dev/null | grep "Config version" | awk -F ':' '{print $2}' | tr -d '[:space:]')

if [[ ! -f "/config/syslog-ng.conf" ]]; then
    cp -a /defaults/syslog-ng.conf /config/syslog-ng.conf
    sed -i "s/|VERSION|/${SYSLOG_VERSION}/" /config/syslog-ng.conf
fi

CONF_VERSION=$(grep -oP "@version: \K(\d+\.\d+)" "/config/syslog-ng.conf")

if [[ -f "/config/syslog-ng.conf" ]] && (( $(bc -l <<< "${CONF_VERSION} < ${SYSLOG_VERSION}") )); then
cat <<-EOF
********************************************************
********************************************************
*                                                      *
*                         !!!!                         *
*    WARNING: Configuration file format is too old,    *
*     syslog-ng is running in compatibility mode.      *
*                                                      *
*   To upgrade the configuration, please review any    *
*    warnings about incompatible changes in the log.   *
*                                                      *
*   Once completed change the @version header at the   *
*       top of the configuration file to "${SYSLOG_VERSION}"        *
*                                                      *
*                                                      *
********************************************************
********************************************************
EOF
fi

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    lsiown -R abc:abc \
        /config
fi

# ===== From ./processed/syslog-ng/root/etc/s6-overlay//s6-rc.d/svc-syslog-ng/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec 2>&1 \
        s6-setuidgid abc /usr/sbin/syslog-ng -F -f /config/syslog-ng.conf --persist-file /config/syslog-ng.persist --pidfile=/config/syslog-ng.pid --control=/config/syslog-ng.ctl --stderr --no-caps
else
    exec 2>&1 \
        /usr/sbin/syslog-ng -F -f /config/syslog-ng.conf --persist-file /config/syslog-ng.persist --pidfile=/config/syslog-ng.pid --control=/config/syslog-ng.ctl --stderr --no-caps
fi

