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

enable_mdns="${ENABLE_MDNS:-false}"

owntone_args=(
    -f
    -c /config/owntone.conf
    -P /config/owntone.pid
)

if [[ "${enable_mdns,,}" != "true" ]]; then
    owntone_args+=(
        --mdns-no-rsp
        --mdns-no-daap
        --mdns-no-cname
        --mdns-no-web
    )
fi

if [[ "$#" -gt 0 ]]; then
    owntone_args+=("$@")
fi

exec /usr/sbin/owntone "${owntone_args[@]}"
