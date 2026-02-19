#!/usr/bin/env bash


# make our folders
mkdir -p \
    /config/dbase_and_logs

if [[ ! -f /config/owntone.conf ]]; then
    cp /etc/owntone.conf.orig /config/owntone.conf
    sed -i \
        -e '/cache_path\ =/ s/# *//' \
        -e '/db_path\ =/ s/# *//' \
        -e s#ipv6\ =\ yes#ipv6\ =\ no#g \
        -e s#My\ Music\ on\ %h#LS.IO\ Music#g \
        -e s#/srv/music#/music#g \
        -e 's/\(uid.*=\).*/\1 \"apps\"/g' \
        -e s#/var/cache/owntone/cache.db#/config/dbase_and_logs/cache.db#g \
        -e s#/var/cache/owntone/songs3.db#/config/dbase_and_logs/songs3.db#g \
        -e s#/var/log/owntone.log#/config/dbase_and_logs/owntone.log#g \
        -e '/trusted_networks\ =/ s/# *//' \
        -e 's#trusted_networks = {.*#trusted_networks = { "lan" }#' \
        -e '/admin_password\ =/ s/# *//' \
        -e 's#admin_password = .*#admin_password = "changeme"#' \
        /config/owntone.conf
fi

exec /usr/sbin/owntone -f -c /config/owntone.conf -P /config/owntone.pid
