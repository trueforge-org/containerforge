# ===== From ./processed/resilio-sync/root/etc/s6-overlay//s6-rc.d/init-resilio-sync-config/run =====
#!/usr/bin/with-contenv bash

# copy config
if [[ ! -e /config/sync.conf ]]; then
    cp /defaults/sync.conf /config/sync.conf
fi

# permissions
lsiown -R abc:abc \
    /config

lsiown abc:abc \
    /sync

# ===== From ./processed/resilio-sync/root/etc/s6-overlay//s6-rc.d/svc-resilio-sync/run =====
#!/usr/bin/with-contenv bash

  exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8888" \
        s6-setuidgid abc rslsync \
        --nodaemon --config /config/sync.conf

