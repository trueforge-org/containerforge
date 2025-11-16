# ===== From ./processed/kavita/root/etc/s6-overlay//s6-rc.d/init-kavita-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ! -f "/config/appsettings.json" ]]; then
    cp /defaults/appsettings-init.json /config/
fi

# permissions

    /app/kavita/wwwroot/index.html

# ===== From ./processed/kavita/root/etc/s6-overlay//s6-rc.d/svc-kavita/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
        cd /app/kavita /app/kavita/Kavita

