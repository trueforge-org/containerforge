# ===== From ./processed/ddclient/root/etc/s6-overlay//s6-rc.d/init-ddclient-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make our folders
mkdir -p \
    /run/ddclient-cache \
    /run/ddclient

# copy default config if not present in /config
if [[ ! -e /config/ddclient.conf ]]; then
    cp /defaults/ddclient.conf /config
fi

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    # permissions
    lsiown -R abc:abc \
        /config \
        /run/ddclient \
        /run/ddclient-cache
fi

chmod 700 \
    /config \
    /run/ddclient-cache

chmod 600 \
    /config/*

# ===== From ./processed/ddclient/root/etc/s6-overlay//s6-rc.d/svc-ddclient/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-setuidgid abc /usr/bin/ddclient --foreground --file /config/ddclient.conf --cache /run/ddclient-cache/ddclient.cache
else
    exec \
        /usr/bin/ddclient --foreground --file /config/ddclient.conf --cache /run/ddclient-cache/ddclient.cache
fi

# ===== From ./processed/ddclient/root/etc/s6-overlay//s6-rc.d/svc-inotify/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# starting inotify to watch /config/ddclient.conf and restart ddclient if changed.
while inotifywait -e modify /config/ddclient.conf; do
    if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
        lsiown abc:abc /config/ddclient.conf
    fi
    chmod 600 /config/ddclient.conf
    s6-svc -h /run/service/svc-ddclient
    echo "ddclient has been restarted"
done

