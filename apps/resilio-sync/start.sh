# ===== From ./processed/resilio-sync/root/etc/s6-overlay//s6-rc.d/init-resilio-sync-config/run =====
#!/usr/bin/with-contenv bash

# copy config
if [[ ! -e /config/sync.conf ]]; then
    cp /defaults/sync.conf /config/sync.conf
fi

# permissions

# ===== From ./processed/resilio-sync/root/etc/s6-overlay//s6-rc.d/svc-resilio-sync/run =====
#!/usr/bin/with-contenv bash

  exec \
            rslsync \
        --nodaemon --config /config/sync.conf

