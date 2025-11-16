# ===== From ./processed/kavita/root/etc/s6-overlay//s6-rc.d/init-kavita-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ! -f "/config/appsettings.json" ]]; then
    cp /defaults/appsettings-init.json /config/
fi

# permissions
lsiown -R abc:abc \
    /config \
    /app/kavita/wwwroot/index.html

# ===== From ./processed/kavita/root/etc/s6-overlay//s6-rc.d/svc-kavita/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 5000" \
    cd /app/kavita s6-setuidgid abc /app/kavita/Kavita

