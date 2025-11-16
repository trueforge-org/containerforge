# ===== From ./processed/htpcmanager/root/etc/s6-overlay//s6-rc.d/init-htpcmanager-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# permissions
lsiown -R abc:abc \
    /app \
    /config

# ===== From ./processed/htpcmanager/root/etc/s6-overlay//s6-rc.d/svc-htpcmanager/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8085" \
        s6-setuidgid abc python3 /app/htpcmanager/Htpc.py \
        --datadir /config

# ===== From ./processed/htpcmanager/root/etc/s6-overlay//s6-rc.d/svc-vnstat/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    vnstatd -n

