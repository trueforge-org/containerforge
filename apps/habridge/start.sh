# ===== From ./processed/habridge/root/etc/s6-overlay//s6-rc.d/init-habridge-config/run =====
#!/usr/bin/with-contenv bash

# make folders
mkdir -p \
    /config/scripts \

# copy config file
if [[ ! -e /config/ha-bridge.config ]]; then
    cp /defaults/ha-bridge.config /config/ha-bridge.config
fi

# set permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/habridge/root/etc/s6-overlay//s6-rc.d/svc-habridge/run =====
#!/usr/bin/with-contenv bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8080" \
        s6-setuidgid abc java \
            -jar \
            -Dconfig.file=/config/ha-bridge.config \
            -Dexec.garden=/config/scripts \
            -Dsecurity.key="$SEC_KEY" \
            /app/ha-bridge.jar

