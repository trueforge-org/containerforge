# ===== From ./processed/adguardhome-sync/root/etc/s6-overlay//s6-rc.d/init-adguardhome-sync-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ! -f "/config/adguardhome-sync.yaml" ]]; then
    cp -a /defaults/adguardhome-sync.yaml /config/adguardhome-sync.yaml
fi

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    lsiown -R abc:abc \
        /config
fi

# ===== From ./processed/adguardhome-sync/root/etc/s6-overlay//s6-rc.d/svc-adguardhome-sync/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 \
            s6-setuidgid abc /app/adguardhome-sync/adguardhome-sync run --config "${CONFIGFILE:-/config/adguardhome-sync.yaml}"
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 \
            /app/adguardhome-sync/adguardhome-sync run --config "${CONFIGFILE:-/config/adguardhome-sync.yaml}"
fi

