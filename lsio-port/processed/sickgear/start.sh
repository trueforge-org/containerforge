# ===== From ./processed/sickgear/root/etc/s6-overlay//s6-rc.d/init-sickgear-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

#make our folders and links
mkdir -p \
    /config

# If needed add dafault config
if [[ ! -f /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/sickgear/root/etc/s6-overlay//s6-rc.d/svc-sickgear/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8081" \
        s6-setuidgid abc python3 /app/sickgear/sickgear.py --datadir /config

