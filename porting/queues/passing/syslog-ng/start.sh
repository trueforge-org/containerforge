#!/usr/bin/env bash


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
exec 2>&1 \
         /usr/sbin/syslog-ng -F -f /config/syslog-ng.conf --persist-file /config/syslog-ng.persist --pidfile=/config/syslog-ng.pid --control=/config/syslog-ng.ctl --stderr --no-caps
